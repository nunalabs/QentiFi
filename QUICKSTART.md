# 🚀 Guía Rápida: Conectarse a ANDE Network

## ✅ Lo que YA está listo:

1. **Smart Contracts** - 8 contratos implementados y testeados
2. **Frontend** - Páginas de Home, Create, Explore, Token Detail
3. **Wagmi Config** - ANDE Network configurado (Testnet: Chain ID 42069)
4. **RainbowKit** - Wallet connection integrado
5. **Hooks** - React hooks para interactuar con contratos

## 🎯 Para conectarte AHORA mismo a ANDE:

### Paso 1: Configurar WalletConnect (2 minutos)

```bash
# 1. Ve a https://cloud.walletconnect.com/
# 2. Crea una cuenta gratis
# 3. Crea un nuevo proyecto
# 4. Copia el "Project ID"

# 5. Actualiza el .env.local que acabo de crear:
cd apps/web
nano .env.local
# Reemplaza YOUR_PROJECT_ID_HERE con tu Project ID real
```

### Paso 2: Agregar ANDE Network a tu Wallet (1 minuto)

Abre MetaMask (o tu wallet preferida) y agrega la red manualmente:

**ANDE Testnet:**
- **Network Name:** ANDE Testnet
- **RPC URL:** `https://rpc-testnet.ande.network`
- **Chain ID:** `42069`
- **Currency Symbol:** ANDE
- **Block Explorer:** `https://explorer-testnet.ande.network`

### Paso 3: Obtener ANDE de testnet (2 minutos)

```bash
# Ve al faucet de ANDE:
# https://faucet.ande.network

# Ingresa tu dirección de wallet
# Recibe ANDE tokens gratis para testing
```

### Paso 4: Iniciar la App (30 segundos)

```bash
cd /home/user/QentiFi

# Instalar dependencias (si no lo has hecho)
pnpm install

# Iniciar frontend
cd apps/web
pnpm run dev

# La app estará en http://localhost:3000
```

### Paso 5: ¡Conectar tu Wallet!

1. Abre `http://localhost:3000`
2. Click en "Connect Wallet" (botón de RainbowKit)
3. Selecciona tu wallet (MetaMask, Rainbow, etc.)
4. Cambia a ANDE Testnet en tu wallet
5. **¡Listo! Ya estás conectado a ANDE Network** 🎉

## 🔍 ¿Qué puedes hacer AHORA?

### Sin contratos deployados:
- ✅ Ver la interfaz completa
- ✅ Conectar tu wallet a ANDE Network
- ✅ Explorar las páginas (Home, Create, Explore)
- ✅ Ver los componentes visuales
- ❌ Crear tokens (necesitas deployment)
- ❌ Hacer trades (necesitas deployment)

### Después del deployment:
- ✅ Crear meme tokens
- ✅ Comprar/vender en bonding curve
- ✅ Agregar liquidez
- ✅ Stake tokens
- ✅ Ganar NFT badges
- ✅ Ver charts de precio

## 📝 Comandos Útiles

```bash
# Ver la app en desarrollo
pnpm run dev

# Construir para producción
pnpm run build

# Verificar tipos TypeScript
pnpm run type-check

# Ver logs en tiempo real
tail -f .next/trace
```

## 🚨 Troubleshooting Rápido

**Error: "Failed to connect"**
```
Solución: Verifica que ANDE Testnet esté agregada a tu wallet
```

**Error: "Missing WalletConnect Project ID"**
```
Solución: Actualiza .env.local con tu Project ID real
```

**La app no carga:**
```bash
# Limpia caché y reinstala
rm -rf .next node_modules
pnpm install
pnpm run dev
```

**Wallet no cambia de red:**
```
Solución: Cambia manualmente a ANDE Testnet en tu wallet
```

## 📱 Wallets Compatibles

- ✅ MetaMask
- ✅ Rainbow
- ✅ Coinbase Wallet
- ✅ WalletConnect
- ✅ Trust Wallet
- ✅ Ledger

## 🎨 Features Visuales Disponibles

1. **Home Page** (`/`)
   - Hero section con gradiente Qenti
   - Cards de features
   - Stats overview
   - Connect wallet button

2. **Create Token** (`/create`)
   - Form de creación
   - Preview de imagen
   - Upload a IPFS (después de configurar Pinata)

3. **Explore** (`/explore`)
   - Grid de tokens
   - Search y filtros
   - Sort por market cap / volume

4. **Token Detail** (`/token/[address]`)
   - Chart de precio (TradingView)
   - Trading interface (Buy/Sell)
   - Token stats
   - Graduation progress bar

## ⏭️ Próximos Pasos

### Para deployar contratos:

```bash
cd packages/contracts

# 1. Configurar .env
cp .env.example .env
nano .env  # Agregar tu PRIVATE_KEY

# 2. Obtener ANDE de testnet
# https://faucet.ande.network

# 3. Deployar
./script/DeployTestnet.sh

# 4. Actualizar frontend con addresses
# Las addresses estarán en deployments/ande-testnet.json
```

## 🎉 Conclusión

**SÍ, ya puedes conectarte a ANDE Network!**

Solo necesitas:
1. ✅ WalletConnect Project ID (gratis, 2 min)
2. ✅ Agregar ANDE a tu wallet (1 min)
3. ✅ `pnpm run dev` (30 seg)

Para funcionalidad completa (crear tokens, trading), necesitas deployar los contratos primero con `./script/DeployTestnet.sh`.

---

**¿Tienes tu WalletConnect Project ID? Actualiza `.env.local` y ejecuta `pnpm run dev`** 🚀
