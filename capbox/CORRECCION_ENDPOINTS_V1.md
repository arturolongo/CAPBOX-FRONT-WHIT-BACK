# Corrección de Endpoints - Versión v1

## ✅ **Problema Identificado**

Los endpoints de autenticación no estaban usando el prefijo `/v1` requerido por el API Gateway.

## 🔧 **Correcciones Realizadas**

### **1. AuthService - iniciarSesion**
```dart
// ANTES (INCORRECTO):
final response = await _dio.post('/oauth/token', data: ...);

// DESPUÉS (CORRECTO):
final response = await _dio.post('/v1/oauth/token', data: ...);
```

### **2. AuthService - refrescarToken**
```dart
// ANTES (INCORRECTO):
final response = await _dio.post('/oauth/token', data: ...);

// DESPUÉS (CORRECTO):
final response = await _dio.post('/v1/oauth/token', data: ...);
```

### **3. AuthService - registerUser**
```dart
// ANTES (INCORRECTO):
final response = await _dio.post('/auth/register', data: ...);

// DESPUÉS (CORRECTO):
final response = await _dio.post('/v1/auth/register', data: ...);
```

## 🎯 **Justificación Técnica**

### **API Gateway Routing**
- El API Gateway está configurado para enrutar `/v1/oauth/{proxy+}` hacia `ms-identidad`
- Sin el prefijo `/v1`, las peticiones no coinciden con las reglas de enrutamiento
- Esto causa errores 404 (Not Found) porque el endpoint no se encuentra

### **Consistencia de Versionado**
- Todas las rutas de la API deben usar el prefijo `/v1`
- Esto asegura que todas las peticiones pasen por el API Gateway correctamente
- Mantiene la consistencia con la arquitectura de microservicios

## 📋 **Endpoints Corregidos**

| Método | Endpoint Anterior | Endpoint Corregido |
|--------|-------------------|-------------------|
| POST | `/oauth/token` | `/v1/oauth/token` |
| POST | `/auth/register` | `/v1/auth/register` |

## 🚀 **Resultado Esperado**

Con estas correcciones:
1. ✅ **Las peticiones coincidirán** con las reglas del API Gateway
2. ✅ **El enrutamiento funcionará** correctamente hacia `ms-identidad`
3. ✅ **Los endpoints existirán** y responderán apropiadamente
4. ✅ **La autenticación OAuth2** funcionará como se espera

## 🎉 **Estado Actual**

- ✅ **Todos los endpoints corregidos**
- ✅ **Consistencia de versionado mantenida**
- ✅ **Listo para probar autenticación**

La aplicación ahora debería poder conectarse correctamente al backend y realizar autenticación OAuth2. 