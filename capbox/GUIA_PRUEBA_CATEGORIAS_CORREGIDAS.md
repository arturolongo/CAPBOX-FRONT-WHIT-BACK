# 🧪 GUÍA DE PRUEBA: Categorías de Ejercicios Corregidas

## 📋 **Objetivo**
Verificar que la corrección del backend para las categorías de ejercicios funcione correctamente.

## 🎯 **Pasos de Verificación**

### **1. Crear Rutina de Prueba**

#### **A. Ir a la página de crear rutina**
- Navegar a: Coach → Crear Rutina
- Completar nombre: "Prueba Categorías Corregidas"
- Nivel: Principiante

#### **B. Agregar ejercicios de cada categoría**

**Ejercicio 1 - Calentamiento:**
- Nombre: "Estiramiento de Hombros"
- Descripción: "Rotación de hombros"
- Sets/Reps: "10 repeticiones"
- Duración: 120 segundos
- Categoría: Calentamiento

**Ejercicio 2 - Resistencia:**
- Nombre: "Burpees"
- Descripción: "Salto con flexión"
- Sets/Reps: "5 x 10"
- Duración: 300 segundos
- Categoría: Resistencia

**Ejercicio 3 - Técnica:**
- Nombre: "Jab-Cross"
- Descripción: "Combinación básica"
- Sets/Reps: "3 x 20"
- Duración: 180 segundos
- Categoría: Técnica

#### **C. Crear la rutina**
- Hacer clic en "Crear Rutina"
- Verificar que se cree exitosamente (código 201)

### **2. Verificar en Gestión de Rutinas**

#### **A. Ir a Gestionar Rutinas**
- Navegar a: Coach → Gestionar Rutinas
- Seleccionar nivel: Principiante
- Buscar la rutina "Prueba Categorías Corregidas"

#### **B. Verificar categorías en la UI**
- **Sección Calentamiento**: Debe mostrar "Estiramiento de Hombros"
- **Sección Resistencia**: Debe mostrar "Burpees"
- **Sección Técnica**: Debe mostrar "Jab-Cross"

#### **C. Verificar logs del backend**
En la consola del navegador, buscar logs como:
```
🔍 [CoachManageRoutinePage] Ejercicio: Estiramiento de Hombros
  - Categoría del backend: "calentamiento"
✅ [CoachManageRoutinePage] Agregado a categoría: calentamiento

🔍 [CoachManageRoutinePage] Ejercicio: Burpees
  - Categoría del backend: "resistencia"
✅ [CoachManageRoutinePage] Agregado a categoría: resistencia

🔍 [CoachManageRoutinePage] Ejercicio: Jab-Cross
  - Categoría del backend: "tecnica"
✅ [CoachManageRoutinePage] Agregado a categoría: tecnica
```

### **3. Verificar Rutinas Existentes**

#### **A. Probar rutinas anteriores**
- "prueba" (debería tener ejercicios en calentamiento)
- "Rutina normal" (debería tener ejercicios en resistencia)
- "Velocidad epica" (debería tener ejercicios distribuidos)

#### **B. Verificar que no haya ejercicios en categoría incorrecta**
- Ningún ejercicio de resistencia debe aparecer en técnica
- Ningún ejercicio de calentamiento debe aparecer en resistencia
- Todos los ejercicios deben estar en su categoría correcta

## ✅ **Criterios de Éxito**

### **✅ CORRECTO (Backend arreglado):**
- ✅ Ejercicios aparecen en sus categorías correctas
- ✅ Logs muestran categorías correctas del backend
- ✅ No hay ejercicios en categorías incorrectas
- ✅ Todas las rutinas (nuevas y existentes) funcionan

### **❌ INCORRECTO (Backend aún con problemas):**
- ❌ Ejercicios aparecen en categorías incorrectas
- ❌ Logs muestran "tecnica" para ejercicios de resistencia
- ❌ Ejercicios de calentamiento aparecen en técnica
- ❌ Categorías inconsistentes entre rutinas

## 🔍 **Logs a Verificar**

### **Logs Correctos:**
```
📊 [RoutineService] Response data:
{id: xxx, nombre: Prueba Categorías Corregidas, ejercicios: [
  {id: estiramiento_xxx, nombre: Estiramiento de Hombros, categoria: calentamiento},
  {id: burpees_xxx, nombre: Burpees, categoria: resistencia},
  {id: jab_cross_xxx, nombre: Jab-Cross, categoria: tecnica}
]}

🔍 [CoachManageRoutinePage] Ejercicio: Estiramiento de Hombros
  - Categoría del backend: "calentamiento"
✅ [CoachManageRoutinePage] Agregado a categoría: calentamiento
```

### **Logs Incorrectos (Problema persiste):**
```
📊 [RoutineService] Response data:
{id: xxx, nombre: Prueba Categorías Corregidas, ejercicios: [
  {id: estiramiento_xxx, nombre: Estiramiento de Hombros, categoria: tecnica},
  {id: burpees_xxx, nombre: Burpees, categoria: tecnica},
  {id: jab_cross_xxx, nombre: Jab-Cross, categoria: tecnica}
]}

🔍 [CoachManageRoutinePage] Ejercicio: Estiramiento de Hombros
  - Categoría del backend: "tecnica"
⚠️ [CoachManageRoutinePage] Categoría no válida: tecnica, agregando a técnica
```

## 🚨 **Si el Problema Persiste**

### **1. Verificar Backend:**
- Confirmar que el backend está actualizado
- Verificar logs del backend para errores
- Comprobar que la base de datos tiene los datos correctos

### **2. Limpiar Cache:**
- Reiniciar la aplicación Flutter
- Limpiar cache del navegador (si es web)
- Verificar que no hay datos en caché

### **3. Reportar al Backend:**
Si el problema persiste, proporcionar:
- Logs completos de la creación de rutina
- Logs completos de la consulta de rutina
- Screenshots de la UI mostrando categorías incorrectas

## 📞 **Reporte de Resultados**

### **Formato del Reporte:**
```
✅ PRUEBA COMPLETADA

Rutina Creada: [Nombre de la rutina]
Fecha: [Fecha de la prueba]

RESULTADOS:
- Calentamiento: [Ejercicios mostrados]
- Resistencia: [Ejercicios mostrados]  
- Técnica: [Ejercicios mostrados]

LOGS VERIFICADOS:
- Categorías del backend: [Correctas/Incorrectas]
- Errores encontrados: [Ninguno/Detalles]

CONCLUSIÓN:
- ✅ Backend corregido
- ❌ Problema persiste
```

---

**Esta guía permite verificar de manera sistemática si la corrección del backend funciona correctamente.** 🧪 