# 🔐 Verificación del Autorizador JWT - AWS API Gateway

## 🎯 **Pasos Específicos para el Equipo Backend**

### **1. Acceder al API Gateway**
1. Ve a AWS Console
2. Navega a API Gateway
3. Selecciona tu API `CapBOX-Gateway`

### **2. Verificar el Autorizador**
1. En el menú izquierdo, ve a **"Autorización"**
2. Busca el autorizador `CapBOX-Cognito-Authorizer`
3. Haz clic en **"Editar"**

### **3. Verificar Configuración**

#### **Issuer URL (URL del Emisor):**
```
CORRECTO: https://cognito-idp.us-east-1.amazonaws.com/us-east-1_BGLrPMS01
INCORRECTO: https://cognito-idp.us-east-1.amazonaws.com/us-east-1_BGLrPMS01/
INCORRECTO: https://cognito-idp.us-east-1.amazonaws.com/us-east-1_BGLrPMS01 
```

#### **Audience (Audiencia):**
```
CORRECTO: 3tbo7h2b21cna6gj44h8si9g2t
INCORRECTO:  3tbo7h2b21cna6gj44h8si9g2t 
INCORRECTO: "3tbo7h2b21cna6gj44h8si9g2t"
```

### **4. Verificar Claims Mapeados**

En la sección **"Claims de identidad"**, debe tener:

```
sub → userId
username → username
custom:rol → rol
custom:clavegym → clavegym
```

### **5. Verificar Métodos HTTP**

Asegúrate de que los endpoints tengan el autorizador asignado:

- `GET /v1/users/me` → `CapBOX-Cognito-Authorizer`
- `GET /v1/users/me/gym/key` → `CapBOX-Cognito-Authorizer`
- `POST /v1/gyms/link` → `CapBOX-Cognito-Authorizer`

### **6. Probar el Autorizador**

1. Ve a **"Prueba"** en el autorizador
2. Pega un token JWT válido
3. Haz clic en **"Probar autorizador"**
4. Verifica que devuelva los claims correctos

## 🚨 **Problemas Comunes**

### **Error 401 - Token Inválido**
- Verificar Issuer URL
- Verificar Audience
- Verificar que el token no haya expirado

### **Error 403 - Acceso Denegado**
- Verificar mapeo de claims
- Verificar permisos del usuario
- Verificar configuración de CORS

### **Claims Faltantes**
- Verificar que los claims personalizados estén mapeados
- Verificar que el usuario tenga los atributos personalizados

## 📊 **Resultado Esperado**

Si todo está correcto, deberías ver en los logs del microservicio:

```json
{
  "userId": "842824e8-e061-7053-016e-8be9f8bd90e2",
  "username": "842824e8-e061-7053-016e-8be9f8bd90e2",
  "rol": "Administrador",
  "clavegym": "ADMIN_GYM_KEY"
}
```

---
**Guía para verificar la configuración del autorizador JWT** 