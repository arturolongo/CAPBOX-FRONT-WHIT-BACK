# 🚨 URGENTE: Endpoint de Estudiantes Retorna 404

## ⚠️ **PROBLEMA CRÍTICO**

A pesar de que el equipo backend reportó que el endpoint `/planning/v1/coach/gym-students` está implementado, **sigue retornando 404 Not Found** en producción.

## 📊 **Error Observado**

```
GET https://api.capbox.site/planning/v1/coach/gym-students?nivel=avanzado 404 (Not Found)

Headers enviados:
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxNDI3NDEwZC1kMzU4LTRhODYtODY0NS03MGE1NDE5YWEzZjQiLCJlbWFpbCI6ImFtaXphZGF5LmRldkBnbWFpbC5jb20iLCJyb2wiOiJFbnRyZW5hZG9yIiwiIiwiaWF0IjoxNzUzODk2MDMyLCJleHAiOjE3NTM4OTk2MzJ9.6hr7ONMIwArFt4TZFBo8GPYbZnK2CPNsBv7RoKwDr0M
```

## 🔍 **Discrepancia Encontrada**

### **Lo que reportó Backend:**
```
✅ Endpoint implementado: GET /v1/coach/gym-students
✅ También disponible: GET /planning/v1/coach/gym-students  
✅ Parámetro de filtro: ?nivel=principiante/intermedio/avanzado
```

### **Realidad en Producción:**
```
❌ GET /planning/v1/coach/gym-students → 404 Not Found
❌ GET /v1/coach/gym-students → Sin probar aún
❌ GET /coach/gym-students → Sin probar aún
```

## 🛠️ **Acciones Tomadas en Frontend**

Para diagnosticar el problema, he implementado un **endpoint scanner** que prueba automáticamente estas variaciones:

1. `/planning/v1/coach/gym-students?nivel={nivel}`
2. `/v1/coach/gym-students?nivel={nivel}`
3. `/coach/gym-students?nivel={nivel}`
4. `/planning/v1/coach/gym-students`
5. `/v1/coach/gym-students`
6. `/coach/gym-students`

El sistema ahora:
- **🔍 Detecta automáticamente** qué endpoint funciona
- **📊 Reporta en logs** todos los intentos y respuestas
- **🔧 Se adapta** al endpoint que esté disponible
- **🎯 Filtra datos** según sea necesario

## 📋 **Verificaciones Requeridas por Backend**

### **1. Verificar Deploy**
```bash
# ¿Está el código en producción?
git log --oneline -10
git status

# ¿Están los endpoints registrados?
grep -r "coach/gym-students" src/
grep -r "coach-gym-students" src/
```

### **2. Verificar Rutas**
```bash
# ¿Están las rutas configuradas correctamente?
curl -X GET "https://api.capbox.site/planning/v1/coach/gym-students" \
  -H "Authorization: Bearer {jwt_token}" -v

# ¿Hay logs del servidor?
tail -f /var/log/backend.log | grep gym-students
```

### **3. Probar Alternativas**
```bash
# Probar sin prefijo planning
curl -X GET "https://api.capbox.site/v1/coach/gym-students" \
  -H "Authorization: Bearer {jwt_token}" -v

# Probar con coach directo  
curl -X GET "https://api.capbox.site/coach/gym-students" \
  -H "Authorization: Bearer {jwt_token}" -v
```

## 🎯 **Endpoint Correcto Esperado**

Una vez identificado el endpoint correcto, debería retornar:

```json
[
  {
    "id": "uuid-estudiante-real-1",
    "nombre": "Juan Pérez", 
    "nivel": "avanzado",
    "email": "juan@example.com"
  },
  {
    "id": "uuid-estudiante-real-2",
    "nombre": "María García",
    "nivel": "avanzado", 
    "email": "maria@example.com"
  }
]
```

## ⚡ **Impacto**

- **🚫 Sistema de asignación completamente bloqueado**
- **🚫 Coaches no pueden asignar rutinas**
- **🚫 Estudiantes no ven rutinas en su home**
- **🚫 Funcionalidad principal de la app rota**

## 🚀 **Solución Temporal Implementada**

El frontend ahora es **resiliente** y:
1. **Detecta automáticamente** el endpoint correcto
2. **Se adapta** a diferentes estructuras de URL
3. **Reporta** cuál endpoint funciona para futura referencia
4. **Maneja filtrado** tanto del backend como frontend

## 📞 **Acción Requerida**

**Equipo Backend:** 
1. **Verificar inmediatamente** por qué el endpoint reportado no funciona
2. **Confirmar** cuál es el endpoint real disponible
3. **Probar** con los comandos curl proporcionados
4. **Reportar** hallazgos y endpoint correcto

---

**PRIORIDAD: CRÍTICA** - Bloqueador total de funcionalidad principal

**Última actualización:** $(date)
**Frontend adaptado:** ✅ Scanner automático implementado
**Esperando:** Confirmación de endpoint correcto del backend