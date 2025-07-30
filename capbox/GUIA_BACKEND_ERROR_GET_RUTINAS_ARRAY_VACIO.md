# 🚨 GUÍA BACKEND - ERROR GET /planning/v1/routines RETORNA ARRAY VACÍO

## 🎯 **RESUMEN DEL PROBLEMA**

**Endpoint afectado:** `GET /planning/v1/routines`  
**Síntoma:** Siempre retorna `[]` (array vacío) aunque existen rutinas en la base de datos  
**Estado:** El endpoint responde HTTP 200 (sin errores), pero sin datos  

---

## ✅ **LO QUE FUNCIONA CORRECTAMENTE**

### **1. Creación de rutinas (POST)**
- ✅ `POST /planning/v1/routines` funciona perfectamente
- ✅ Las rutinas se guardan exitosamente en la base de datos
- ✅ Retorna HTTP 201 Created con el ID de la rutina

### **2. Autenticación**
- ✅ Token JWT válido y correctamente procesado
- ✅ Headers de autorización presentes
- ✅ Usuario identificado: `1427410d-d358-4a86-8645-70a5419aa3f4` (Entrenador)

### **3. Respuesta del endpoint**
- ✅ HTTP 200 OK (sin errores de servidor)
- ✅ Respuesta en formato JSON
- ❌ **PROBLEMA:** Siempre retorna `[]` en lugar de las rutinas

---

## 🔍 **DATOS DE DEPURACIÓN**

### **Logs del frontend:**
```
✅ AUTH INTERCEPTOR: Respuesta exitosa 200
✅ API: GET /planning/v1/routines completado  
✅ [RoutineService] Response status: 200
📊 [RoutineService] Response data: []
✅ [RoutineService] 0 rutinas cargadas
```

### **Rutinas creadas anteriormente:**
- **Rutina 1:** `"Rutina normal"` - ID: `f57c93da-b8ff-4514-8f79-9245e9e62484`
- **Rutina 2:** `"Velocidad"` - ID: `fd3fc5d3-1b9f-4f2a-a38b-ca19cf4c2576`
- **Coach ID:** `1427410d-d358-4a86-8645-70a5419aa3f4`
- **Nivel:** `"Principiante"`
- **SportId:** `1` (BOXEO)

---

## 🔧 **PASOS DE DEPURACIÓN REQUERIDOS**

### **1. Verificar datos en base de datos**
```sql
-- Verificar que las rutinas existen
SELECT * FROM routines;

-- Verificar rutinas del coach específico
SELECT * FROM routines 
WHERE coachId = '1427410d-d358-4a86-8645-70a5419aa3f4';

-- Verificar estructura de datos
SELECT id, nombre, nivel, coachId, sportId, createdAt 
FROM routines 
ORDER BY createdAt DESC;
```

### **2. Revisar el código del endpoint GET**
Localizar el archivo del controlador y verificar:

```typescript
// Ejemplo de posibles problemas:

// ¿Está filtrando por coachId correctamente?
const rutinas = await prisma.routine.findMany({
  where: {
    coachId: userId, // ¿Este valor es correcto?
  }
});

// ¿Hay filtros adicionales que pueden estar bloqueando?
const rutinas = await prisma.routine.findMany({
  where: {
    coachId: userId,
    activo: true,     // ¿Las rutinas se crean con activo = true?
    deleted: false,   // ¿Hay un campo deleted que interfiere?
    estado: 'ACTIVA', // ¿Hay validaciones de estado?
  }
});

// ¿El mapeo a DTO está funcionando?
return rutinas.map(rutina => ({
  id: rutina.id,
  nombre: rutina.nombre,
  nivel: rutina.nivel,
  coachId: rutina.coachId,
  sportId: rutina.sportId,
}));
```

### **3. Agregar logs de depuración**
```typescript
// En el controlador o servicio:
console.log('🔍 [GET /routines] Usuario logueado:', userId);
console.log('🔍 [GET /routines] Filtros aplicados:', filtros);
console.log('🔍 [GET /routines] Query SQL:', query);
console.log('🔍 [GET /routines] Resultados de BD:', rutinas);
console.log('🔍 [GET /routines] DTOs mapeados:', rutinasDTOs);
```

### **4. Verificar filtros comunes que pueden causar arrays vacíos**

#### **A. Filtro por coachId:**
```typescript
// ¿El coachId del token coincide con el de las rutinas?
console.log('Token coachId:', tokenData.sub);
console.log('Rutinas en BD:', await prisma.routine.findMany({ 
  select: { coachId: true, nombre: true } 
}));
```

#### **B. Filtro por nivel (si aplica):**
```typescript
// ¿El filtro de nivel está interfiriendo?
// Verificar si el endpoint sin filtro funciona:
const todasRutinas = await prisma.routine.findMany();
console.log('Total rutinas sin filtro:', todasRutinas.length);
```

#### **C. Campos requeridos faltantes:**
```typescript
// ¿Faltan campos requeridos en el DTO?
const rutinas = await prisma.routine.findMany({
  include: {
    sport: true,      // ¿Se necesita esta relación?
    exercises: true,  // ¿Se necesita esta relación?
  }
});
```

### **5. Probar diferentes consultas**
```typescript
// Test 1: Sin filtros
const test1 = await prisma.routine.findMany();
console.log('Test 1 - Sin filtros:', test1.length);

// Test 2: Solo por coachId
const test2 = await prisma.routine.findMany({
  where: { coachId: '1427410d-d358-4a86-8645-70a5419aa3f4' }
});
console.log('Test 2 - Por coachId:', test2.length);

// Test 3: Por ID específico
const test3 = await prisma.routine.findUnique({
  where: { id: 'f57c93da-b8ff-4514-8f79-9245e9e62484' }
});
console.log('Test 3 - Por ID específico:', test3);
```

---

## 🚨 **POSIBLES CAUSAS MÁS COMUNES**

### **1. Error en filtro por coachId (80% probabilidad)**
```typescript
// INCORRECTO:
where: { coachId: req.user.id }  // Si req.user.id es diferente a coachId

// CORRECTO:
where: { coachId: req.user.sub }  // Usar el campo correcto del token
```

### **2. Campos adicionales interfiriendo (15% probabilidad)**
```typescript
// Verificar si hay campos como:
activo: boolean,
deleted: boolean,
estado: string,
visible: boolean,
// Que puedan estar bloqueando la consulta
```

### **3. Error en el mapeo de respuesta (5% probabilidad)**
```typescript
// Verificar que el return no esté vacío:
return rutinas.map(r => rutinaToDTOMapper(r));  // ¿Está funcionando el mapper?
```

---

## 📊 **ESTRUCTURA ESPERADA DE RESPUESTA**

El endpoint debe retornar:
```json
[
  {
    "id": "f57c93da-b8ff-4514-8f79-9245e9e62484",
    "nombre": "Rutina normal",
    "nivel": "Principiante",
    "coachId": "1427410d-d358-4a86-8645-70a5419aa3f4",
    "sportId": 1
  },
  {
    "id": "fd3fc5d3-1b9f-4f2a-a38b-ca19cf4c2576",
    "nombre": "Velocidad",
    "nivel": "Principiante", 
    "coachId": "1427410d-d358-4a86-8645-70a5419aa3f4",
    "sportId": 1
  }
]
```

---

## 🎯 **ACCIONES INMEDIATAS**

### **Paso 1: Verificar BD (2 minutos)**
```sql
SELECT COUNT(*) as total_rutinas FROM routines;
SELECT * FROM routines WHERE coachId = '1427410d-d358-4a86-8645-70a5419aa3f4';
```

### **Paso 2: Agregar logs (5 minutos)**
Agregar logs en el endpoint GET para ver qué está pasando internamente.

### **Paso 3: Probar sin filtros (3 minutos)**
Temporalmente remover todos los filtros `WHERE` y ver si retorna algo.

### **Paso 4: Verificar coachId (5 minutos)**
Confirmar que el `coachId` del token coincide con el de las rutinas en BD.

---

## 📧 **INFORMACIÓN PARA RESPUESTA**

Cuando resuelvas el problema, por favor comparte:
1. **La causa exacta del error**
2. **El código corregido**
3. **Confirmación de que las rutinas ahora se listan correctamente**

---

## ⚡ **PRIORIDAD: ALTA**

Este bug bloquea completamente la funcionalidad de gestión de rutinas en el frontend. 
La creación funciona, pero la visualización no, lo que hace que la aplicación parezca que no guarda nada.

---

**Fecha:** $(date)  
**Reportado por:** Frontend Team  
**Endpoint:** `GET /planning/v1/routines`  
**Tipo:** Bug crítico - Array vacío en respuesta  