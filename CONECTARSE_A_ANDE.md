# 🚀 Cómo Conectarse a ANDE Network AHORA

## ✅ Estado Actual: LISTO para conectar!

Ya tienes TODO configurado para conectarte a ANDE Network:

- ✅ Configuración de Wagmi con ANDE (Chain ID: 42069)
- ✅ RainbowKit integrado
- ✅ Frontend completo (4 páginas)
- ✅ Componentes UI listos
- ✅ Archivo `.env.local` creado

## 🎯 3 Pasos para Conectarte (5 minutos total)

### Paso 1: Obtener WalletConnect Project ID (2 min - GRATIS)

```bash
1. Ve a: https://cloud.walletconnect.com/
2. Crea cuenta (gratis, con email o GitHub)
3. Click "Create New Project"
4. Copia el "Project ID"
```

### Paso 2: Actualizar .env.local (30 seg)

```bash
cd /home/user/QentiFi/apps/web

# Edita .env.local y reemplaza YOUR_PROJECT_ID_HERE
nano .env.local

# O usa este comando:
sed -i 's/YOUR_PROJECT_ID_HERE/TU_PROJECT_ID_REAL/' .env.local
```

### Paso 3: Iniciar la App (1 min)

```bash
# Si pnpm install aún no terminó, espera a que complete

# Luego:
cd /home/user/QentiFi/apps/web
pnpm run dev

# Abre tu navegador en: http://localhost:3000
```

## 🦊 Configurar MetaMask con ANDE

Una vez que la app cargue:

1. Click en "Connect Wallet"
2. Selecciona MetaMask (o tu wallet favorita)
3. En MetaMask, click en el dropdown de redes
4. Click "Add Network" → "Add a network manually"
5. Ingresa estos datos:

```
Network Name: ANDE Testnet
RPC URL: https://rpc-testnet.ande.network
Chain ID: 42069
Currency Symbol: ANDE
Block Explorer: https://explorer-testnet.ande.network
```

6. Click "Save"
7. Cambia a "ANDE Testnet"

## 💰 Obtener ANDE de Testnet

```bash
# Ve al faucet:
https://faucet.ande.network

# Ingresa tu address de wallet
# Recibirás ANDE tokens gratis en ~30 segundos
```

## 🎉 ¡Listo! Ya estás conectado

Verás:
- ✅ Botón "Connect Wallet" cambia a tu address
- ✅ Network badge muestra "ANDE Testnet"
- ✅ Balance de ANDE en tu wallet
- ✅ Puedes navegar por todas las páginas

## 🔧 Si algo no funciona:

**La app no inicia:**
```bash
# Espera a que pnpm install termine
# Luego:
cd /home/user/QentiFi/apps/web
pnpm run dev
```

**"Missing WalletConnect Project ID":**
```bash
# Verifica que .env.local tenga el Project ID real
cat .env.local | grep WALLETCONNECT
```

**Wallet no se conecta:**
```bash
# 1. Verifica que agregaste ANDE Testnet a MetaMask
# 2. Cambia manualmente a ANDE Testnet en MetaMask
# 3. Recarga la página
```

## 📋 Checklist de Conexión

- [ ] WalletConnect Project ID obtenido
- [ ] .env.local actualizado con Project ID
- [ ] `pnpm install` completado
- [ ] `pnpm run dev` corriendo
- [ ] ANDE Testnet agregada a MetaMask
- [ ] Wallet conectada a la app
- [ ] ANDE tokens recibidos del faucet

## 🚀 Próximo Paso: Deploy de Contratos

Para funcionalidad completa (crear tokens, trading):

```bash
cd /home/user/QentiFi/packages/contracts

# 1. Configurar .env con tu private key
cp .env.example .env
nano .env

# 2. Deployar contratos
./script/DeployTestnet.sh

# 3. Actualizar frontend con addresses deployadas
# (las addresses estarán en deployments/ande-testnet.json)
```

---

**¿Listo? Ejecuta `cd /home/user/QentiFi/apps/web && pnpm run dev`** 🎯
