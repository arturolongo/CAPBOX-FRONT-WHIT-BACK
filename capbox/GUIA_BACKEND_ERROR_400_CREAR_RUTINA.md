# 🔧 GUÍA BACKEND - ERROR 400 CREAR RUTINA

## 📅 **Fecha**: 30 de Enero de 2025
## 🎯 **Para**: Equipo Backend - Planning Service
## 📝 **De**: Frontend - Sistema de Entrenamiento

---

## 🚨 **PROBLEMA ACTUAL**

### **Error 400 en POST /planning/v1/routines**
```
❌ POST https://api.capbox.site/planning/v1/routines 400 (Bad Request)
❌ Error: "Client error - the request contains bad syntax or cannot be fulfilled"
```

---

## 📋 **DATOS QUE ENVÍA EL FRONTEND**

### **Estructura JSON que se está enviando:**
```json
{
  "nombre": "Normalona",
  "nivel": "Principiante", 
  "sportId": "1",
  "descripcion": "ni una",
  "ejercicios": [
    {
      "id": "sentadilla_1234567890",
      "nombre": "Sentadilla",
      "descripcion": null,
      "setsReps": "3 x 90",
      "duracionEstimadaSegundos": 900,
      "categoria": "calentamiento"
    },
    {
      "id": "caminata_1234567891", 
      "nombre": "Caminata",
      "descripcion": null,
      "setsReps": "900 mts",
      "duracionEstimadaSegundos": 1500,
      "categoria": "resistencia"
    },
    {
      "id": "ahhh_1234567892",
      "nombre": "ahhh",
      "descripcion": "ahh", 
      "setsReps": "90x60",
      "duracionEstimadaSegundos": 6000,
      "categoria": "tecnica"
    }
  ]
}
```

### **Headers de la petición:**
```
Content-Type: application/json
Authorization: Bearer {jwt_token}
```

---

## 🔍 **POSIBLES CAUSAS DEL ERROR 400**

### **1. Validación de Campos Requeridos**
- ❌ **Falta validación** para campos obligatorios
- ❌ **Campo `sportId`** espera `int` pero recibe `string`
- ❌ **Campo `categoria`** no está en la validación del backend

### **2. Estructura de Datos Incorrecta**
- ❌ **Campo `id`** en ejercicios no está definido en el modelo
- ❌ **Campo `categoria`** no existe en la tabla de ejercicios
- ❌ **Formato de `setsReps`** no coincide con el esperado

### **3. Validación de Tipos de Datos**
- ❌ **`duracionEstimadaSegundos`** espera `int` pero recibe `string`
- ❌ **`descripcion`** espera `string` pero recibe `null`

### **4. Validación de Enums/Categorías**
- ❌ **`categoria`** valores no están en la lista permitida
- ❌ **`nivel`** valores no coinciden con los definidos

---

## 🛠️ **SOLUCIONES PARA EL BACKEND**

### **1. Actualizar Modelo de Ejercicio**
```sql
-- Agregar campo categoria a la tabla de ejercicios
ALTER TABLE ejercicios ADD COLUMN categoria VARCHAR(20);

-- Agregar constraint para valores válidos
ALTER TABLE ejercicios ADD CONSTRAINT check_categoria 
CHECK (categoria IN ('calentamiento', 'resistencia', 'tecnica'));
```

### **2. Actualizar DTO de Crear Rutina**
```java
// Ejemplo en Java/Spring
public class CreateRoutineRequest {
    @NotBlank
    private String nombre;
    
    @NotBlank
    private String nivel;
    
    @NotNull
    private String sportId; // Cambiar de int a String
    
    private String descripcion;
    
    @NotEmpty
    private List<CreateExerciseRequest> ejercicios;
}

public class CreateExerciseRequest {
    @NotBlank
    private String id; // Agregar campo id
    
    @NotBlank
    private String nombre;
    
    private String descripcion;
    
    @NotBlank
    private String setsReps;
    
    @NotNull
    private Integer duracionEstimadaSegundos;
    
    @NotBlank
    private String categoria; // Agregar campo categoria
}
```

### **3. Actualizar Validaciones**
```java
// Validación de categorías
@Pattern(regexp = "^(calentamiento|resistencia|tecnica)$", 
         message = "Categoría debe ser: calentamiento, resistencia o tecnica")
private String categoria;

// Validación de niveles
@Pattern(regexp = "^(Principiante|Intermedio|Avanzado)$", 
         message = "Nivel debe ser: Principiante, Intermedio o Avanzado")
private String nivel;
```

### **4. Actualizar Base de Datos**
```sql
-- Insertar categorías válidas
INSERT INTO categorias_ejercicios (nombre) VALUES 
('calentamiento'),
('resistencia'), 
('tecnica');

-- Actualizar ejercicios existentes con categoría por defecto
UPDATE ejercicios SET categoria = 'resistencia' WHERE categoria IS NULL;
```

---

## 📊 **ESTRUCTURA ESPERADA POR FRONTEND**

### **Response de Éxito:**
```json
{
  "id": "rutina-uuid-generado",
  "nombre": "Normalona",
  "nivel": "Principiante",
  "sportId": "1",
  "descripcion": "ni una",
  "ejercicios": [
    {
      "id": "ejercicio-uuid-generado",
      "nombre": "Sentadilla",
      "descripcion": null,
      "setsReps": "3 x 90",
      "duracionEstimadaSegundos": 900,
      "categoria": "calentamiento"
    }
  ],
  "fechaCreacion": "2025-01-30T10:00:00Z",
  "coachId": "coach-uuid-del-token"
}
```

### **Response de Error (400):**
```json
{
  "error": "VALIDATION_ERROR",
  "message": "Datos de entrada inválidos",
  "details": [
    {
      "field": "ejercicios[0].categoria",
      "message": "Categoría 'calentamiento' no es válida"
    },
    {
      "field": "sportId", 
      "message": "sportId debe ser un número entero"
    }
  ]
}
```

---

## 🔧 **PASOS PARA RESOLVER**

### **1. Verificar Logs del Backend**
```bash
# Buscar en logs del Planning Service
grep "POST /planning/v1/routines" /var/log/planning-service.log
grep "400" /var/log/planning-service.log
```

### **2. Probar Endpoint Manualmente**
```bash
curl -X POST https://api.capbox.site/planning/v1/routines \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer {token}" \
  -d '{
    "nombre": "Test Routine",
    "nivel": "Principiante",
    "sportId": "1",
    "descripcion": "Test",
    "ejercicios": [
      {
        "id": "test_123",
        "nombre": "Test Exercise",
        "descripcion": null,
        "setsReps": "3x10",
        "duracionEstimadaSegundos": 300,
        "categoria": "calentamiento"
      }
    ]
  }'
```

### **3. Verificar Validaciones**
- ✅ **Campos requeridos** están definidos
- ✅ **Tipos de datos** coinciden
- ✅ **Enums/categorías** están permitidos
- ✅ **Modelo de base de datos** tiene todos los campos

---

## 🎯 **PRIORIDADES DE IMPLEMENTACIÓN**

### **🔥 CRÍTICO (Bloqueante)**
1. **Agregar campo `categoria`** a tabla de ejercicios
2. **Actualizar validaciones** para aceptar `sportId` como string
3. **Agregar campo `id`** a ejercicios en creación

### **⚡ ALTA**
4. **Mejorar mensajes de error** para debugging
5. **Validar categorías** (calentamiento/resistencia/tecnica)

### **📈 MEDIA**
6. **Logs detallados** para debugging
7. **Tests unitarios** para validaciones

---

## 📞 **COORDINACIÓN**

**Frontend está listo y esperando:**
- ✅ Estructura de datos correcta
- ✅ Validaciones en frontend
- ✅ Manejo de errores implementado
- ✅ UI completa funcionando

**Una vez resuelto el error 400, el sistema estará 100% funcional.**

---

## 🚀 **RESULTADO ESPERADO**

**Al completar estas correcciones:**
1. ✅ **POST /planning/v1/routines** retorna 201 Created
2. ✅ **Rutinas se crean** correctamente en base de datos
3. ✅ **Ejercicios con categorías** se guardan
4. ✅ **Frontend puede crear** rutinas sin errores
5. ✅ **Sistema completo** funcionando

**¿Pueden confirmar cuándo estarán listas estas correcciones?** 