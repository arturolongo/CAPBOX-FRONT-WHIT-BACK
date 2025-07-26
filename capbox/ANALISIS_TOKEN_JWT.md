# 🔍 Análisis del Token JWT - CapBOX

## 📋 **Instrucciones para el Equipo Backend**

### **Paso 1: Obtener el Token**
1. Ejecuta la aplicación Flutter
2. Inicia sesión con cualquier usuario
3. Busca en los logs la línea que dice: `🔍 AWS: TOKEN COMPLETO PARA ANÁLISIS:`
4. Copia el token completo (es muy largo, asegúrate de copiarlo completo)

### **Paso 2: Decodificar el Token**
1. Ve a https://jwt.io
2. Pega el token en el campo "Encoded"
3. En la sección "Decoded" -> "PAYLOAD", busca estos campos:

#### **Campos Críticos a Verificar:**

```json
{
  "iss": "https://cognito-idp.us-east-1.amazonaws.com/us-east-1_BGLrPMS01",
  "aud": "3tbo7h2b21cna6gj44h8si9g2t",
  "sub": "842824e8-e061-7053-016e-8be9f8bd90e2",
  "username": "842824e8-e061-7053-016e-8be9f8bd90e2",
  "client_id": "3tbo7h2b21cna6gj44h8si9g2t",
  "token_use": "access",
  "scope": "aws.cognito.signin.user.admin",
  "auth_time": 1753500220,
  "exp": 1753503820,
  "iat": 1753500220
}
```

### **Paso 3: Verificar Configuración del Autorizador**

En AWS API Gateway, verifica que el autorizador `CapBOX-Cognito-Authorizer` tenga:

#### **Configuración Correcta:**
- **Issuer URL**: `https://cognito-idp.us-east-1.amazonaws.com/us-east-1_BGLrPMS01`
- **Audience**: `3tbo7h2b21cna6gj44h8si9g2t`

#### **Errores Comunes a Verificar:**
- ❌ Espacios en blanco al final
- ❌ Barras `/` extra al final de la URL
- ❌ Caracteres especiales mal copiados
- ❌ Mayúsculas/minúsculas incorrectas

### **Paso 4: Verificar Mapeo de Claims**

El autorizador debe mapear estos claims:
- `sub` → `userId`
- `username` → `username`
- `custom:rol` → `rol` (si existe)

## 🚨 **Posibles Problemas**

### **1. Discrepancia en Issuer URL**
```
Token: "iss": "https://cognito-idp.us-east-1.amazonaws.com/us-east-1_BGLrPMS01"
Autorizador: https://cognito-idp.us-east-1.amazonaws.com/us-east-1_BGLrPMS01/  ← BARRAS EXTRA
```

### **2. Discrepancia en Audience**
```
Token: "aud": "3tbo7h2b21cna6gj44h8si9g2t"
Autorizador: " 3tbo7h2b21cna6gj44h8si9g2t "  ← ESPACIOS EXTRA
```

### **3. Claims no mapeados**
El autorizador debe incluir los claims personalizados:
- `custom:rol`
- `custom:clavegym`

## 📊 **Resultado Esperado**

Si todo está correcto, el token debería pasar la validación y llegar al microservicio con:
```json
{
  "userId": "842824e8-e061-7053-016e-8be9f8bd90e2",
  "username": "842824e8-e061-7053-016e-8be9f8bd90e2",
  "rol": "Administrador",
  "clavegym": "ADMIN_GYM_KEY"
}
```

---
**Documento para análisis del token JWT y verificación del autorizador** 