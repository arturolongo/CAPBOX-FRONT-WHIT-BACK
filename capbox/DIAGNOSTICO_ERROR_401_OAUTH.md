# 🔍 DIAGNÓSTICO ERROR 401 OAUTH - FRONTEND FLUTTER

## 📋 PROBLEMA IDENTIFICADO:
Error 401 (Unauthorized) en POST /identity/v1/oauth/token

## 🔧 DIAGNÓSTICO IMPLEMENTADO POR BACKEND:

El backend ha agregado logs detallados para identificar exactamente dónde falla la autenticación:

### 1. **Logs en OAuthController:**
- Grant type recibido
- Client ID y username (email)
- Validación de cliente
- Validación de credenciales de usuario

### 2. **Logs en AuthService:**
- Búsqueda de usuario por email
- Verificación de password
- Estado de verificación del usuario
- Auto-activación de coaches/admins pendientes

### 3. **Logs en generación de tokens:**
- Configuración JWT (issuer, audience, secrets)
- Generación de access token
- Generación de refresh token
- Actualización en base de datos

## 📊 INSTRUCCIONES PARA EL FRONTEND:

### 1. **Intentar login nuevamente** y revisar los logs del backend

### 2. **Verificar que los datos enviados sean correctos:**
```dart
// Ejemplo de datos que debe enviar el frontend
{
  "grant_type": "password",
  "client_id": "capbox-mobile-app",
  "client_secret": "capbox-secret-key-2024",
  "username": "email_del_usuario@ejemplo.com",
  "password": "password_del_usuario"
}
```

### 3. **Verificar en los logs del backend:**
- Si el usuario se encuentra en la base de datos
- Si el password es válido
- Si el usuario está verificado
- Si las variables de entorno JWT están configuradas

## ⚠️ POSIBLES CAUSAS:
1. **Usuario no existe** en la base de datos
2. **Password incorrecto**
3. **Usuario no verificado** (email no confirmado)
4. **Variables de entorno JWT** no configuradas
5. **Cliente OAuth** inválido

## 🎯 RESULTADO ESPERADO:
Después de revisar los logs, podremos identificar exactamente dónde falla y corregir el problema específico.

## 📞 SIGUIENTE PASO:
Una vez que el frontend intente login nuevamente, revisar los logs del backend y compartir la información para identificar la causa exacta del error 401.

---

**Fecha**: Enero 2025
**Estado**: 🔍 EN DIAGNÓSTICO
**Prioridad**: 🔴 CRÍTICA 