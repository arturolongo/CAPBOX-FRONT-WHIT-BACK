# 🗝️ NUEVO SISTEMA DE CLAVES DE GIMNASIO

## 📋 **Descripción del Nuevo Sistema**

El sistema de claves de gimnasio ha sido actualizado para que cada clave esté basada en el nombre del gimnasio, siguiendo un formato específico y predecible.

## 🎯 **Formato de Clave**

### **Estructura:**
```
PRIMERAS_3_LETRAS + al menos 4 caracteres adicionales
```

### **Ejemplos:**
- **Gimnasio "Zikar"** → Clave: `ZIK23hk`
- **Gimnasio "Boxing Club"** → Clave: `BOX45mn`
- **Gimnasio "Fight Club"** → Clave: `FIG78ab`
- **Gimnasio "Elite Boxing"** → Clave: `ELI12cd`

## ✅ **Reglas de Validación**

### **1. Prefijo Obligatorio**
- Debe empezar con las **primeras 3 letras** del nombre del gimnasio
- Se convierte automáticamente a **mayúsculas**
- Ejemplo: "Zikar" → `ZIK`, "Boxing Club" → `BOX`

### **2. Sufijo Mínimo**
- Después del prefijo debe tener **al menos 4 caracteres**
- Puede contener **letras y números**
- Longitud total mínima: **7 caracteres**

### **3. Caracteres Permitidos**
- **Letras**: A-Z, a-z
- **Números**: 0-9
- **Sin guiones ni espacios**

## 🔧 **Implementación Técnica**

### **Función de Generación:**
```dart
String generateNewKey(String gymName) {
  // Obtener las primeras 3 letras del nombre del gimnasio
  final prefix = gymName.trim().toUpperCase().substring(0, 3);
  
  // Generar al menos 4 caracteres adicionales
  final random = Random();
  final chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  final suffix = String.fromCharCodes(
    Iterable.generate(4 + random.nextInt(3), 
      (_) => chars.codeUnitAt(random.nextInt(chars.length)))
  );

  return '$prefix$suffix';
}
```

### **Función de Validación:**
```dart
bool isValidKeyFormat(String key, String gymName) {
  // Obtener las primeras 3 letras del nombre del gimnasio
  final expectedPrefix = gymName.trim().toUpperCase().substring(0, 3);
  
  // Verificar que la clave empiece con las 3 letras correctas
  if (!key.toUpperCase().startsWith(expectedPrefix)) {
    return false;
  }

  // Verificar que tenga al menos 7 caracteres totales
  if (key.length < 7) {
    return false;
  }

  // Verificar que después del prefijo tenga al menos 4 caracteres
  final suffix = key.substring(3);
  if (suffix.length < 4) {
    return false;
  }

  return true;
}
```

## 🎨 **Interfaz de Usuario**

### **Página de Administración:**
1. **Campo de Nombre del Gimnasio**: El admin ingresa el nombre
2. **Indicador de Prefijo**: Muestra las 3 letras que debe tener la clave
3. **Generación Automática**: Botón para generar clave basada en el nombre
4. **Validación en Tiempo Real**: Verifica el formato mientras se escribe

### **Validación Visual:**
- ✅ **Prefijo correcto**: La clave empieza con las 3 letras del gimnasio
- ✅ **Longitud mínima**: Al menos 7 caracteres totales
- ✅ **Sufijo válido**: Al menos 4 caracteres después del prefijo

## 🚀 **Ventajas del Nuevo Sistema**

### **1. Predecibilidad**
- Cada gimnasio tiene un prefijo único basado en su nombre
- Fácil identificación del gimnasio por la clave

### **2. Seguridad**
- Sufijo aleatorio de al menos 4 caracteres
- Combinación de letras y números
- Difícil de adivinar

### **3. Usabilidad**
- Fácil de recordar para los usuarios
- Formato consistente en toda la aplicación
- Validación automática

### **4. Escalabilidad**
- Funciona con cualquier nombre de gimnasio
- No hay conflictos entre diferentes gimnasios
- Fácil de implementar en el backend

## 📱 **Flujo de Usuario**

### **Para Administradores:**
1. Ingresa el nombre del gimnasio
2. El sistema muestra el prefijo esperado
3. Genera automáticamente una clave válida
4. Puede editar manualmente si lo desea
5. El sistema valida el formato en tiempo real

### **Para Entrenadores/Atletas:**
1. Reciben la clave del administrador
2. La ingresan en el formulario de activación
3. El sistema valida el formato básico
4. Se vincula al gimnasio correspondiente

## 🔄 **Migración**

### **Claves Existentes:**
- Las claves existentes seguirán funcionando
- No se requiere migración inmediata
- Los administradores pueden actualizar gradualmente

### **Nuevas Claves:**
- Todas las nuevas claves seguirán el nuevo formato
- Generación automática basada en el nombre del gimnasio
- Validación estricta del formato

## 📊 **Ejemplos de Uso**

| Nombre del Gimnasio | Prefijo | Clave Generada | Válida |
|---------------------|---------|----------------|--------|
| Zikar | ZIK | ZIK23hk | ✅ |
| Boxing Club | BOX | BOX45mn | ✅ |
| Fight Club | FIG | FIG78ab | ✅ |
| Elite Boxing | ELI | ELI12cd | ✅ |
| Palenque | PAL | PAL90xy | ✅ |

## 🎉 **Conclusión**

El nuevo sistema de claves proporciona:
- **Identificación clara** del gimnasio
- **Seguridad mejorada** con sufijos aleatorios
- **Facilidad de uso** para administradores y usuarios
- **Escalabilidad** para múltiples gimnasios
- **Consistencia** en toda la aplicación

---
*Sistema implementado en la versión actual del proyecto CAPBOX* 