# 🔍 DIAGNÓSTICO TOKEN PLANNING SERVICE - 401 UNAUTHORIZED

## 📅 **Fecha**: 30 de Enero de 2025
## 🎯 **Problema**: Planning Service sigue rechazando tokens válidos con 401

---

## 🚨 **SÍNTOMAS OBSERVADOS**

### **Logs del Frontend:**
```
🔐 AUTH INTERCEPTOR: Token expirado o inválido - usuario debe reautenticarse
❌ API: Error en GET /planning/v1/routines?nivel=Principiante - 401
❌ [RoutineService] ERROR obteniendo rutinas: 401 Unauthorized
📝 [RoutineService] Token de autenticación inválido o expirado
```

### **Problema identificado:**
- ✅ **Backend implementó** JWT validation con `issuer` y `audience`
- ❌ **Frontend sigue recibiendo 401** para Planning Service
- ✅ **Identity Service funciona** correctamente
- ❌ **Planning Service rechaza** el mismo token

---

## 🔍 **POSIBLES CAUSAS**

### **1. Token expirado**
- El token actual puede haber expirado
- Necesita login fresco para obtener nuevo token

### **2. Variables de entorno no aplicadas**
- `JWT_ISSUER_URL` no configurada en Seenode
- `JWT_AUDIENCE` no configurada en Seenode
- Planning Service no reiniciado después de los cambios

### **3. Sincronización de servicios**
- Identity Service usa un secreto/config
- Planning Service usa otro secreto/config diferente
- Los servicios no están sincronizados

### **4. Cache del token**
- Frontend podría estar usando token viejo cacheado
- Secure storage tiene token expirado

---

## 🛠️ **PASOS PARA DIAGNOSTICAR**

### **1. Verificar token actual en frontend:**
```javascript
// En DevTools Console:
localStorage.getItem('flutter.access_token')
// O inspeccionar Secure Storage
```

### **2. Hacer login fresco:**
- Logout completo
- Login nuevo 
- Probar Planning Service inmediatamente

### **3. Verificar configuración backend:**
- Confirmar variables en Seenode:
  - `JWT_ISSUER_URL=https://web-87pckv3zfk3q.up-de-fra1-k8s-1.apps.run-on-seenode.com `
  - `JWT_AUDIENCE=capbox-app`
- Confirmar que Planning Service fue reiniciado

### **4. Verificar logs del Planning Service:**
- Buscar errores específicos de JWT validation
- Verificar que lee correctamente las variables de entorno
- Confirmar que usa el mismo secreto que Identity Service

---

## 🔧 **SOLUCIONES PROPUESTAS**

### **Inmediato - Frontend:**
1. **Logout forzado** y login fresco
2. **Limpiar secure storage** completamente
3. **Obtener token nuevo** del Identity Service

### **Backend - Verificar:**
1. **Variables de entorno** aplicadas correctamente
2. **Reinicio del Planning Service** después de cambios
3. **Logs del Planning Service** para errores específicos
4. **Sincronización** de secretos entre servicios

---

## 🎯 **PRÓXIMOS PASOS**

1. **Hacer logout/login fresco** en frontend
2. **Verificar token nuevo** funciona con Planning Service
3. Si persiste, **revisar logs del Planning Service**
4. Confirmar **variables de entorno** en Seenode

---

## 📋 **ESTADO ACTUAL**

**❌ PENDIENTE** - Token siendo rechazado por Planning Service
**🔄 EN INVESTIGACIÓN** - Causa exacta del 401

**Requiere coordinación Frontend + Backend para resolver.** 