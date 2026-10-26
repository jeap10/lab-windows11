# 🖥️ Laboratorio Windows 11 Pro en VirtualBox

Laboratorio práctico de **instalación, configuración y administración básica de Windows 11 Pro** en una máquina virtual, orientado a tareas reales de **soporte e infraestructura TI**.

> Autor: **Jerson Palacios** — Estudiante de Ingeniería de Ciberseguridad (UNI)

---

## 📋 Contenido

1. [Requisitos](#1-requisitos)
2. [Creación de la máquina virtual](#2-creación-de-la-máquina-virtual)
3. [Instalación de Windows 11 Pro](#3-instalación-de-windows-11-pro)
4. [Configuración inicial (cuenta local)](#4-configuración-inicial-cuenta-local)
5. [Guest Additions](#5-guest-additions)
6. [Red: ipconfig y subneteo](#6-red-ipconfig-y-subneteo)
7. [Usuarios y grupos locales](#7-usuarios-y-grupos-locales)
8. [Windows Update](#8-windows-update)
9. [Instalación de programas con winget](#9-instalación-de-programas-con-winget)
10. [Sincronización de hora](#10-sincronización-de-hora)
11. [Buenas prácticas de seguridad](#11-buenas-prácticas-de-seguridad)
12. [Próximos pasos](#12-próximos-pasos)

---

## 1. Requisitos

| Recurso | Detalle |
|---|---|
| Hipervisor | [Oracle VirtualBox](https://www.virtualbox.org/) 7.x |
| Sistema operativo | [ISO de Windows 11 x64](https://www.microsoft.com/es-es/software-download/windows11) (multi-edición) |
| Equipo anfitrión | 16 GB+ de RAM recomendado, CPU x64 con virtualización activada |

> 💡 **Buena práctica:** guardar las máquinas virtuales en una carpeta propia (ej. `C:\VM`) y **no** en OneDrive u otra carpeta sincronizada, porque pesan mucho y la sincronización puede corromperlas.

En VirtualBox: **Preferencias → General → Carpeta predeterminada de máquinas →** `C:\VM`

---

## 2. Creación de la máquina virtual

| Parámetro | Valor |
|---|---|
| Nombre | `Win11-Practica` |
| Tipo / Versión | Microsoft Windows / Windows 11 (64-bit) |
| Memoria RAM | 4096 MB |
| Procesadores | 2 |
| Disco | 64 GB, VDI, **reservado dinámicamente** |
| Firmware | **EFI** activado |
| Seguridad | **TPM 2.0** y **Secure Boot** activados (requisitos de Windows 11) |
| Instalación desatendida | ❌ Omitida (para hacer la instalación manual) |

> 📝 Disco **dinámico**: solo ocupa en el equipo real el espacio que realmente usa la VM.

---

## 3. Instalación de Windows 11 Pro

1. Iniciar la VM y **presionar una tecla** cuando aparezca `Press any key to boot from CD or DVD...`
   - Si no se presiona a tiempo, la VM no encuentra sistema operativo → montar la ISO de nuevo y reintentar.
2. Idioma: **Español (México)** · Teclado: **Latinoamericano**
3. **Instalar Windows 11** → *No tengo una clave de producto*
4. Edición: **Windows 11 Pro** (permite unirse a un dominio; Home no)
5. Aceptar licencia
6. Disco: seleccionar **Espacio sin asignar (64 GB)** → Windows crea las particiones automáticamente (EFI, recuperación y principal)
7. Instalar y esperar. En los reinicios **no presionar ninguna tecla**.

> 💡 En un equipo físico se usa un **USB booteable** creado con la *Media Creation Tool* o con [Rufus](https://rufus.ie/es/). Para una instalación limpia se eliminan las particiones antiguas.

---

## 4. Configuración inicial (cuenta local)

1. País: **Perú** · Teclado: **Latinoamericano** (omitir segunda distribución)
2. Nombre del equipo según estándar (ej. `PC-PRACTICA01`)
3. **Configurar para uso profesional o educativo**
4. **Opciones de inicio de sesión → Unirse a un dominio en su lugar** → crea una **cuenta local** sin cuenta Microsoft

**Si no aparece la opción**, presionar `Shift + F10` y ejecutar:

```cmd
start ms-cxh:localonly
```

5. Privacidad: desactivar todas las opciones.
6. Actualizaciones durante la instalación: **Actualizar más tarde** (se hacen luego desde Windows Update).

> 🏢 En una empresa, en este paso el equipo se une al **dominio (Active Directory)** o a **Entra ID / Intune**, y la privacidad se controla de forma centralizada con **GPO** o **Intune**.

---

## 5. Guest Additions

Drivers de VirtualBox para que la resolución se ajuste a la ventana y el mouse funcione mejor.

1. Menú VirtualBox: **Dispositivos → Insertar imagen de CD de las Guest Additions**
2. En la VM: **Este equipo → Unidad de CD (D:) VirtualBox Guest Additions**
3. Ejecutar **`VBoxWindowsAdditions-amd64.exe`** (64 bits) → Instalar → **Reboot now**
4. Expulsar el CD: **Dispositivos → Unidades ópticas → Remove Disk From Virtual Drive**

> 📝 **amd64 = x64 = 64 bits** (Intel o AMD). **x86** = 32 bits.

---

## 6. Red: ipconfig y subneteo

```cmd
ipconfig            :: IP, máscara y puerta de enlace
ipconfig /all       :: + MAC, servidor DHCP, DNS, DHCP habilitado
ipconfig /release   :: libera la IP obtenida por DHCP
ipconfig /renew     :: solicita una IP nueva al DHCP
ipconfig /flushdns  :: limpia la caché DNS
nslookup google.com :: consulta qué IP tiene un nombre
```

### Resultado obtenido en la VM (modo NAT de VirtualBox)

| Dato | Valor |
|---|---|
| Dirección IPv4 | `10.0.2.15` |
| Máscara | `255.255.255.0` (**/24**) |
| Puerta de enlace | `10.0.2.2` |

### Cálculo de subred

| Dato | Valor |
|---|---|
| Bloque | 256 − 0 = 256 |
| **Red** | `10.0.2.0` |
| **Rango de hosts** | `10.0.2.1` – `10.0.2.254` |
| **Broadcast** | `10.0.2.255` |
| **Hosts usables** | 2⁸ − 2 = **254** |

**Método:** IP + máscara → prefijo → bloque (256 − octeto de la máscara) → red → broadcast → hosts.

| Prefijo | Máscara | Bloque | Hosts |
|---|---|---|---|
| /24 | 255.255.255.0 | 256 | 254 |
| /25 | 255.255.255.128 | 128 | 126 |
| /26 | 255.255.255.192 | 64 | 62 |
| /27 | 255.255.255.224 | 32 | 30 |
| /28 | 255.255.255.240 | 16 | 14 |
| /29 | 255.255.255.248 | 8 | 6 |
| /30 | 255.255.255.252 | 4 | 2 |

### Conceptos

- **Dirección de red:** identifica a toda la subred (no se asigna a equipos).
- **Host:** cualquier dispositivo con IP (PC, impresora, servidor, router).
- **Broadcast:** envía un mensaje a todos los equipos de la red (no se asigna a equipos).
- **Puerta de enlace:** router por donde se sale a otras redes o a internet.
- **DNS:** traduce nombres a direcciones IP. Clave para Active Directory.
- **DHCP:** asigna IP, máscara, gateway y DNS automáticamente (proceso **DORA**: Discover, Offer, Request, Acknowledge).
- **`169.254.x.x` (APIPA):** el equipo no obtuvo respuesta del DHCP → revisar cable/Wi-Fi, servidor DHCP, ámbito agotado o VLAN sin DHCP relay.

---

## 7. Usuarios y grupos locales

### Por comandos (CMD como administrador)

```cmd
:: Listar usuarios
net user

:: Crear usuario (el * pide la contraseña sin mostrarla en pantalla)
net user practicante * /add

:: Agregar el usuario al grupo Administradores
net localgroup Administradores practicante /add

:: Ver información de un usuario
net user practicante

:: Eliminar usuario
net user practicante /delete
```

> 🔐 Usar `*` en lugar de escribir la contraseña evita que quede visible en pantalla o en el historial.
>
> 📝 `net user ... /delete` borra la cuenta pero **no** su carpeta de perfil `C:\Users\usuario` si ya inició sesión.

### Por consola gráfica

- `Win + R` → **`lusrmgr.msc`** (Usuarios y grupos locales). Disponible en **Pro / Enterprise / Education**, no en Home.
- **Configuración → Cuentas → Otros usuarios → Agregar cuenta → No tengo los datos de inicio de sesión → Agregar un usuario sin cuenta de Microsoft**.

### Cuentas integradas observadas

| Cuenta | Descripción |
|---|---|
| Administrador | Administrador integrado, **deshabilitado** por defecto |
| Invitado | Cuenta de invitado, **deshabilitada** por defecto |
| DefaultAccount | Cuenta interna del sistema |
| WDAGUtilityAccount | Cuenta interna de Windows Defender Application Guard |

> 🏢 En un dominio, los usuarios y grupos se gestionan centralmente en **Active Directory**, no en cada equipo.

---

## 8. Windows Update

**Configuración → Windows Update → Buscar actualizaciones → Descargar e instalar → Reiniciar**

- **Historial de actualizaciones:** calidad, seguridad, Defender y controladores.
- **Opciones avanzadas → Horas activas:** evitar reinicios en horario laboral.
- **Pausar actualizaciones:** útil si un parche causa problemas.
- El botón de reinicio permite **programar** el reinicio.

> 🏢 En empresas las actualizaciones se gestionan de forma centralizada con **WSUS** (on-premise) o **Intune**.

---

## 9. Instalación de programas con winget

**winget** es el gestor de paquetes de Windows: instala, actualiza y desinstala programas desde fuentes oficiales y **verifica el hash** del instalador.

```cmd
winget search acrobat                               :: buscar un programa
winget install --id 7zip.7zip -e                     :: instalar por Id exacto
winget install --id Google.Chrome -e
winget install --id Adobe.Acrobat.Reader.64-bit -e
winget list                                          :: ver programas instalados
winget upgrade                                       :: ver actualizaciones disponibles
winget upgrade --all                                 :: actualizar todo
winget uninstall --id 7zip.7zip -e                   :: desinstalar
```

- `--id` + `-e` (exact): asegura que se instale exactamente el paquete correcto.
- Columna **Source**: `winget` (repositorio comunitario) o `msstore` (Microsoft Store).

### Automatizar la preparación de un equipo

Ver [`scripts/instalar-programas.bat`](scripts/instalar-programas.bat): instala el software estándar en modo silencioso.

```cmd
:: Copiar la lista de programas de un equipo a otro
winget export -o programas.json
winget import -i programas.json
```

---

## 10. Sincronización de hora

**Configuración → Hora e idioma → Fecha y hora → Establecer la hora automáticamente → Sincronizar ahora**

```cmd
w32tm /resync
```

> 🔐 La hora es crítica en Active Directory: **Kerberos tolera ~5 minutos de diferencia**; con más desfase falla el inicio de sesión en el dominio. También es clave para correlacionar **logs** en un incidente.

---

## 11. Buenas prácticas de seguridad

- ✅ Usar **cuentas estándar** para el trabajo diario; administrador solo para TI (**mínimo privilegio**).
- ✅ Mantener deshabilitadas las cuentas integradas **Administrador** e **Invitado**.
- ✅ No escribir contraseñas en texto plano en comandos (`net user usuario *`).
- ✅ Mantener el sistema **actualizado** (parches de seguridad).
- ✅ Instalar software solo desde **fuentes oficiales** (winget verifica el hash).
- ✅ No exponer **RDP (3389)** a internet; acceder por VPN o Bastion.
- ✅ Desactivar opciones de privacidad innecesarias.

---

## 12. Próximos pasos

- [ ] Instalar **Windows Server 2022** (Evaluation) en otra VM
- [ ] Configurar **Active Directory Domain Services** y **DNS**, y promover a controlador de dominio
- [ ] Poner ambas VMs en la misma **red interna**
- [ ] **Unir Windows 11 al dominio** e iniciar sesión con un usuario del dominio
- [ ] Crear **OUs, usuarios, grupos** y aplicar **GPO**

---

## 📁 Estructura del repositorio

```
lab-windows11/
├── README.md
├── scripts/
│   ├── instalar-programas.bat   # Instalación silenciosa de software con winget
│   └── usuarios.bat             # Gestión de usuarios locales
└── capturas/                    # Capturas de pantalla del laboratorio
```
