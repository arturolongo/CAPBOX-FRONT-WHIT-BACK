# 🔄 Actualización de Endpoints - API v1 Corregida

## 📋 Cambios Realizados

### 🗝️ **Endpoint de Clave del Gimnasio**
- **Antes**: `/v1/profile/gym/key`
- **Ahora**: `/v1/users/me/gym/key`

### 📁 **Archivos Actualizados**

1. **`lib/core/services/aws_api_service.dart`**
   - `getMyGymKey()`: `/v1/users/me/gym/key`
   - `getAdminGymKey()`: `/v1/users/me/gym/key`
   - `updateAdminGymKey()`: `/v1/users/me/gym/key`

2. **`lib/core/api/api_config.dart`**
   - Agregado: `userGymKey = '/v1/users/me/gym/key'`

3. **`lib/features/coach/data/services/gym_key_service.dart`**
   - Actualizado log para mostrar endpoint correcto

4. **`lib/features/admin/data/services/admin_gym_key_service.dart`**
   - Actualizado log para mostrar endpoint correcto

## ✅ **Endpoints Confirmados por Backend**

### Autenticación
- ✅ `POST /v1/auth/register`
- ✅ `POST /v1/oauth/token`
- ✅ `POST /v1/auth/token/refresh`
- ✅ `POST /v1/auth/forgot-password`
- ✅ `POST /v1/auth/reset-password`
- ✅ `POST /v1/auth/logout`

### Usuarios
- ✅ `GET /v1/users/me`
- ✅ `GET /v1/users/me/gym/key` (NUEVO)
- ✅ `PATCH /v1/users/me/gym/key` (NUEVO)
- ✅ `GET /v1/users/{id}`

### Gimnasios
- ✅ `POST /v1/gyms/link`
- ✅ `GET /v1/gyms/{gymId}/members`

### Solicitudes
- ✅ `GET /v1/requests/pending`
- ✅ `POST /v1/athletes/{atletaId}/approve`

## 🚀 **Estado Actual**

**Todos los endpoints han sido actualizados para coincidir con la nueva especificación del backend.**

### Próximos Pasos:
1. Probar la aplicación con los nuevos endpoints
2. Verificar que la obtención de clave del gimnasio funcione
3. Confirmar que la actualización de clave del admin funcione

---
**Actualización realizada según la nueva especificación del equipo backend** 