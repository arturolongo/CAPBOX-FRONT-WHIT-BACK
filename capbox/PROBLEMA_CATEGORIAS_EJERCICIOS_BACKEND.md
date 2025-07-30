# 🚨 PROBLEMA: Categorías de Ejercicios No Se Guardan Correctamente

## 📋 **Descripción del Problema**

El frontend está enviando las categorías correctas (`calentamiento`, `resistencia`, `tecnica`) pero el backend está guardando **algunos ejercicios con categorías incorrectas**, especialmente muchos se guardan como `categoria: "tecnica"` por defecto.

## 🔍 **Evidencia del Problema - Logs Reales**

### **✅ Ejemplos que FUNCIONAN correctamente:**

**Rutina "prueba":**
```json
{
  "ejercicios": [
    {
      "nombre": "Calentamiento",
      "categoria": "calentamiento",  // ← CORRECTO
      "setsReps": "50"
    },
    {
      "nombre": "Risistencia", 
      "categoria": "tecnica",        // ← INCORRECTO: debería ser "resistencia"
      "setsReps": "50"
    },
    {
      "nombre": "pepe",
      "categoria": "tecnica",        // ← CORRECTO
      "setsReps": "20"
    }
  ]
}
```

**Rutina "Rutina normal":**
```json
{
  "ejercicios": [
    {
      "nombre": "Burpees",
      "categoria": "resistencia",    // ← CORRECTO
      "setsReps": "8 x 10"
    },
    {
      "nombre": "lagartijajajajas",
      "categoria": "resistencia",    // ← CORRECTO
      "setsReps": "80 x 2"
    },
    {
      "nombre": "golpe recto",
      "categoria": "tecnica",        // ← CORRECTO
      "setsReps": "500 golpes"
    }
  ]
}
```

### **❌ Ejemplos que FALLAN completamente:**

**Rutina "Velocidad epica":**
```json
{
  "ejercicios": [
    {
      "nombre": "Calen 1",
      "categoria": "tecnica",        // ← INCORRECTO: debería ser "calentamiento"
      "setsReps": "20"
    },
    {
      "nombre": "calen 2",
      "categoria": "tecnica",        // ← INCORRECTO: debería ser "calentamiento"
      "setsReps": "50 x 2"
    },
    {
      "nombre": "Res 1",
      "categoria": "tecnica",        // ← INCORRECTO: debería ser "resistencia"
      "setsReps": "50"
    },
    {
      "nombre": "Tec 1",
      "categoria": "tecnica",        // ← CORRECTO
      "setsReps": "50"
    }
  ]
}
```

## 🎯 **Patrón Identificado**

- ✅ **`"calentamiento"`** se guarda correctamente en algunos casos
- ✅ **`"resistencia"`** se guarda correctamente en algunos casos
- ❌ **Muchos ejercicios se guardan como `"tecnica"` por defecto**

## 🔧 **Posibles Causas en Backend**

### **1. Validación Inconsistente**
```typescript
// ❌ PROBLEMA: Validación que funciona a veces pero no siempre
if (!['calentamiento', 'resistencia', 'tecnica'].includes(categoria)) {
  categoria = 'tecnica'; // ← Esto puede estar causando el problema
}
```

### **2. Default Value Incorrecto**
```typescript
// ❌ PROBLEMA: Default que se aplica incorrectamente
const categoria = ejercicio.categoria || 'tecnica';
```

### **3. Mapeo de DTO Inconsistente**
```typescript
// ❌ PROBLEMA: Mapeo que funciona a veces pero no siempre
const ejercicio = {
  id: data.id,
  nombre: data.nombre,
  categoria: data.categoria || 'tecnica', // ← Puede estar causando el problema
};
```

## 🛠️ **Solución Requerida**

### **1. Verificar Endpoint POST `/planning/v1/routines`**
- **PROBLEMA:** Algunas categorías se guardan correctamente, otras no
- **CAUSA POSIBLE:** Validación inconsistente o default value incorrecto
- **SOLUCIÓN:** Asegurar que el campo `categoria` se guarde exactamente como viene del frontend

### **2. Verificar Endpoint GET `/planning/v1/routines/{id}`**
- **PROBLEMA:** Las categorías incorrectas se devuelven tal como se guardaron
- **SOLUCIÓN:** No aplicar transformaciones que cambien la categoría

### **3. Verificar Base de Datos**
- **PROBLEMA:** Campo `categoria` puede tener constraints o defaults incorrectos
- **SOLUCIÓN:** Verificar que no haya triggers o defaults que fuercen "tecnica"

## 📝 **Logs de Debug Sugeridos**

Agregar estos logs en el backend para identificar el patrón:

```typescript
// En POST /planning/v1/routines
console.log('📥 [Backend] Categoría recibida del frontend:', ejercicio.categoria);
console.log('📥 [Backend] Categoría antes de guardar:', categoria);
console.log('📥 [Backend] Categoría después de guardar:', savedCategoria);

// En GET /planning/v1/routines/{id}  
console.log('📤 [Backend] Categoría leída de BD:', dbCategoria);
console.log('📤 [Backend] Categoría enviada al frontend:', ejercicio.categoria);
```

## ✅ **Resultado Esperado**

Después de la corrección, TODAS las rutinas deben devolver categorías correctas:

```json
{
  "ejercicios": [
    {
      "nombre": "Calen 1",
      "categoria": "calentamiento",  // ← SIEMPRE correcto
      "setsReps": "20"
    },
    {
      "nombre": "Res 1", 
      "categoria": "resistencia",    // ← SIEMPRE correcto
      "setsReps": "50"
    },
    {
      "nombre": "Tec 1",
      "categoria": "tecnica",        // ← SIEMPRE correcto
      "setsReps": "50"
    }
  ]
}
```

## 🚀 **Prioridad**

**ALTA** - Este problema afecta la funcionalidad principal de gestión de rutinas. Algunas categorías funcionan pero otras no, lo que indica un bug inconsistente en el backend.

---

**Equipo Backend:** Por favor revisar y corregir este problema para que TODAS las categorías se guarden y devuelvan correctamente, no solo algunas. 