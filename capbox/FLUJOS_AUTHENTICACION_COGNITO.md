# Flujos de Autenticación de Cognito

## 🔄 **Flujos Disponibles**

### **1. USER_PASSWORD_AUTH**
```dart
'AuthFlow': 'USER_PASSWORD_AUTH'
```
- **Descripción**: Autenticación directa con email y contraseña
- **Requisitos**: App Client debe tener habilitado este flujo
- **Estructura**: `AuthParameters: {'USERNAME': email, 'PASSWORD': password}`

### **2. ADMIN_NO_SRP_AUTH**
```dart
'AuthFlow': 'ADMIN_NO_SRP_AUTH'
```
- **Descripción**: Autenticación administrativa sin SRP
- **Requisitos**: App Client debe tener habilitado este flujo
- **Estructura**: `AuthParameters: {'USERNAME': email, 'PASSWORD': password}`

### **3. USER_SRP_AUTH**
```dart
'AuthFlow': 'USER_SRP_AUTH'
```
- **Descripción**: Autenticación con protocolo SRP (más seguro)
- **Requisitos**: App Client debe tener habilitado este flujo
- **Estructura**: `AuthParameters: {'USERNAME': email, 'SRP_A': 'A'}`

## 🚨 **Problema Actual**

El `SerializationException` indica que:
1. **El flujo no está habilitado** en el App Client
2. **La estructura JSON no es correcta** para el flujo elegido
3. **Faltan parámetros requeridos** para el flujo

## ✅ **Solución Recomendada**

### **Probar ADMIN_NO_SRP_AUTH primero:**
```dart
final requestData = {
  'AuthFlow': 'ADMIN_NO_SRP_AUTH',
  'ClientId': '3tbo7h2b21cna6gj44h8si9g2t',
  'AuthParameters': {
    'USERNAME': email,
    'PASSWORD': password,
  },
};
```

### **Si no funciona, verificar configuración del App Client:**
1. **AWS Console** → Cognito → User Pools
2. **Seleccionar User Pool** → App Clients
3. **Verificar flujos habilitados** en el App Client

## 📋 **Próximos Pasos**

1. **Probar ADMIN_NO_SRP_AUTH**
2. **Si falla, verificar configuración del App Client**
3. **Habilitar flujos necesarios** en AWS Console
4. **Probar USER_PASSWORD_AUTH** una vez habilitado

## 🎯 **Resultado Esperado**

Una vez que el flujo correcto esté habilitado:
- ✅ **SerializationException desaparecerá**
- ✅ **Login funcionará correctamente**
- ✅ **Tokens JWT se obtendrán** 