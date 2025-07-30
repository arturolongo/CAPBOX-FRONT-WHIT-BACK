# 🚨 PROBLEMA ESPECÍFICO: Categoría "resistencia" No Se Guarda Correctamente

## 📋 **Descripción del Problema**

Después de las correcciones del backend, las categorías funcionan parcialmente:
- ✅ **`"calentamiento"`** se guarda correctamente
- ❌ **`"resistencia"`** se guarda como `"tecnica"`
- ✅ **`"tecnica"`** se guarda correctamente

## 🔍 **Evidencia del Problema**

### **Logs Reales de Prueba:**

**Rutina "Pruebaaaaa" creada con:**
- **Calentamiento:** "Hombros" → `categoria: "calentamiento"` ✅
- **Resistencia:** "Pepe" → `categoria: "tecnica"` ❌ (debería ser "resistencia")
- **Técnica:** "Teec" → `categoria: "tecnica"` ✅

### **Resultado en Frontend:**
```
📊 [CoachManageRoutinePage] Resumen de categorías para Pruebaaaaa:
  - calentamiento: 1 ejercicios  ← ✅ CORRECTO
  - resistencia: 0 ejercicios    ← ❌ INCORRECTO (debería ser 1)
  - tecnica: 2 ejercicios        ← ❌ INCORRECTO (debería ser 1)
```

## 🎯 **Patrón Identificado**

El problema es **específico a la categoría "resistencia"**:
- ✅ `"calentamiento"` → se guarda como `"calentamiento"`
- ❌ `"resistencia"` → se guarda como `"tecnica"`
- ✅ `"tecnica"` → se guarda como `"tecnica"`

## 🔧 **Posibles Causas Específicas**

### **1. Validación Inconsistente para "resistencia"**
```typescript
// ❌ PROBLEMA: Validación que falla específicamente con "resistencia"
if (!['calentamiento', 'resistencia', 'tecnica'].includes(categoria)) {
  categoria = 'tecnica';
}
// Posible problema: "resistencia" no está siendo reconocida como válida
```

### **2. Default Value Incorrecto**
```typescript
// ❌ PROBLEMA: Default que se aplica a "resistencia"
const categoria = ejercicio.categoria || 'tecnica';
// Si "resistencia" llega como null/undefined, se convierte en "tecnica"
```

### **3. Mapeo de DTO Específico**
```typescript
// ❌ PROBLEMA: Mapeo que falla con "resistencia"
const ejercicio = {
  id: data.id,
  nombre: data.nombre,
  categoria: data.categoria || 'tecnica', // ← "resistencia" se convierte en "tecnica"
};
```

### **4. Problema en Base de Datos**
```sql
-- ❌ PROBLEMA: Constraint o trigger que afecta "resistencia"
-- Posible trigger que convierte "resistencia" en "tecnica"
```

## 🛠️ **Solución Requerida**

### **1. Verificar Validación de Categorías**
```typescript
// ✅ SOLUCIÓN: Validación explícita
const categoriasValidas = ['calentamiento', 'resistencia', 'tecnica'];
console.log('🔍 [Backend] Categoría recibida:', categoria);
console.log('🔍 [Backend] Es válida?', categoriasValidas.includes(categoria));

if (!categoriasValidas.includes(categoria)) {
  console.warn('⚠️ [Backend] Categoría inválida:', categoria);
  categoria = 'tecnica';
}
```

### **2. Verificar Default Value**
```typescript
// ✅ SOLUCIÓN: No usar default para categorías válidas
let categoria = ejercicio.categoria;
if (!categoria) {
  console.warn('⚠️ [Backend] Categoría es null/undefined, usando default');
  categoria = 'tecnica';
} else {
  console.log('✅ [Backend] Categoría válida:', categoria);
}
```

### **3. Verificar Mapeo de DTO**
```typescript
// ✅ SOLUCIÓN: Preservar categoría exacta
const ejercicio = {
  id: data.id,
  nombre: data.nombre,
  categoria: data.categoria, // ← NO usar || 'tecnica'
};
```

### **4. Verificar Base de Datos**
```sql
-- ✅ SOLUCIÓN: Verificar que no hay triggers/constraints
-- Revisar si hay triggers que convierten "resistencia" en "tecnica"
```

## 📝 **Logs de Debug Específicos**

Agregar estos logs específicos para "resistencia":

```typescript
// En POST /planning/v1/routines
console.log('📥 [Backend] Categoría recibida del frontend:', ejercicio.categoria);
console.log('📥 [Backend] Es "resistencia"?', ejercicio.categoria === 'resistencia');
console.log('📥 [Backend] Categoría antes de guardar:', categoria);
console.log('📥 [Backend] Categoría después de guardar:', savedCategoria);

// En GET /planning/v1/routines/{id}  
console.log('📤 [Backend] Categoría leída de BD:', dbCategoria);
console.log('📤 [Backend] Es "resistencia"?', dbCategoria === 'resistencia');
console.log('📤 [Backend] Categoría enviada al frontend:', ejercicio.categoria);
```

## 🧪 **Test Específico para "resistencia"**

### **Crear rutina de prueba con:**
```json
{
  "nombre": "Test Resistencia",
  "ejercicios": [
    {
      "nombre": "Burpees",
      "categoria": "resistencia",  // ← FOCUS AQUÍ
      "setsReps": "10 x 5",
      "duracionEstimadaSegundos": 300
    }
  ]
}
```

### **Resultado Esperado:**
```json
{
  "ejercicios": [
    {
      "nombre": "Burpees",
      "categoria": "resistencia",  // ← DEBE SER "resistencia"
      "setsReps": "10 x 5"
    }
  ]
}
```

### **Resultado Actual (INCORRECTO):**
```json
{
  "ejercicios": [
    {
      "nombre": "Burpees",
      "categoria": "tecnica",      // ← INCORRECTO
      "setsReps": "10 x 5"
    }
  ]
}
```

## 🎯 **Archivos a Revisar**

### **1. consultar-detalles-rutina.service.ts**
- Verificar que "resistencia" se procesa correctamente
- Agregar logs específicos para "resistencia"

### **2. actualizar-rutina.service.ts**
- Verificar que "resistencia" se preserva en actualizaciones
- Agregar logs específicos para "resistencia"

### **3. prisma-ejercicio.repositorio.ts**
- Verificar que "resistencia" se guarda correctamente en BD
- Agregar logs específicos para "resistencia"

### **4. Base de Datos**
- Verificar que no hay triggers/constraints que afecten "resistencia"
- Verificar que el campo `categoria` acepta "resistencia"

## 🚀 **Prioridad**

**ALTA** - Este problema afecta específicamente la categoría "resistencia", que es una categoría fundamental para las rutinas de entrenamiento.

---

**Equipo Backend:** Por favor revisar específicamente por qué la categoría "resistencia" se está convirtiendo en "tecnica" mientras que "calentamiento" funciona correctamente. 