# 🚀 Deploying QentiFi to Vercel

## ⚠️ Important: pnpm Version Issue

Vercel defaults to pnpm 6.x, but QentiFi requires pnpm >=8.0.0.

## ✅ Solution (3 Options)

### Option 1: Configure in Vercel Dashboard (Recommended)

1. Go to your Vercel project settings
2. Navigate to **Settings** → **General** → **Build & Development Settings**
3. Add these environment variables under **Environment Variables**:
   - `ENABLE_EXPERIMENTAL_COREPACK=1`
4. Or set the Node.js version:
   - **Node.js Version**: `18.x`
5. Redeploy

### Option 2: Use the Vercel CLI

```bash
# Install Vercel CLI
npm i -g vercel

# Link your project
vercel link

# Set environment variable
vercel env add ENABLE_EXPERIMENTAL_COREPACK production
# Enter value: 1

# Deploy
vercel --prod
```

### Option 3: Update Vercel Configuration

The repository already includes:
- ✅ `vercel.json` - Build configuration
- ✅ `.npmrc` - pnpm configuration
- ✅ `.node-version` - Node version specification
- ✅ `package.json` with `packageManager: "pnpm@8.15.0"`

Just commit and push:

```bash
git add vercel.json .npmrc .node-version
git commit -m "Add Vercel configuration for pnpm 8.x"
git push
```

Then in Vercel Dashboard:
1. Go to **Settings** → **General**
2. Under **Build & Development Settings**:
   - Build Command: `turbo run build --filter=@qentifi/web`
   - Output Directory: `apps/web/.next`
   - Install Command: `pnpm install`
3. Click **Save**
4. Redeploy

## 🔧 Environment Variables for Vercel

Add these to **Settings** → **Environment Variables**:

### Required:
```
NEXT_PUBLIC_WALLETCONNECT_PROJECT_ID=your_walletconnect_project_id
NEXT_PUBLIC_ANDE_CHAIN_ID=42069
NEXT_PUBLIC_ANDE_RPC_URL=https://rpc-testnet.ande.network
```

### After Contract Deployment:
```
NEXT_PUBLIC_FACTORY_ADDRESS=0x...
NEXT_PUBLIC_POOL_MANAGER_ADDRESS=0x...
NEXT_PUBLIC_QENTI_TOKEN_ADDRESS=0x...
NEXT_PUBLIC_STAKING_VAULT_ADDRESS=0x...
NEXT_PUBLIC_NFT_BADGES_ADDRESS=0x...
```

### Optional (IPFS/Pinata):
```
PINATA_JWT=your_pinata_jwt_token
NEXT_PUBLIC_PINATA_GATEWAY=https://gateway.pinata.cloud/ipfs/
```

### Optional (The Graph):
```
NEXT_PUBLIC_SUBGRAPH_URL=https://api.thegraph.com/subgraphs/name/your-username/qentifi-ande
```

## 📦 Build Configuration

The `vercel.json` file is already configured:

```json
{
  "buildCommand": "turbo run build --filter=@qentifi/web",
  "installCommand": "pnpm install",
  "framework": null,
  "outputDirectory": "apps/web/.next"
}
```

## 🐛 Troubleshooting

### Error: "Unsupported environment (bad pnpm version)"

**Solution**: Enable Corepack in Vercel:
1. Go to project Settings
2. Add environment variable: `ENABLE_EXPERIMENTAL_COREPACK=1`
3. Redeploy

### Error: "Cannot find module '@qentifi/web'"

**Solution**: The build command needs to filter correctly:
```bash
turbo run build --filter=@qentifi/web
```

This is already set in `vercel.json`.

### Error: "Module not found: Can't resolve 'wagmi'"

**Solution**: The `.npmrc` file includes hoisting configuration:
```
public-hoist-pattern[]=*wagmi*
public-hoist-pattern[]=*viem*
shamefully-hoist=true
```

This is already configured.

### Build succeeds but deployment fails

**Solution**: Check these:
1. All environment variables are set
2. `NEXT_PUBLIC_WALLETCONNECT_PROJECT_ID` is valid
3. Contract addresses are valid (if deployed)

## 🎯 Quick Deploy Checklist

- [ ] Commit `vercel.json`, `.npmrc`, `.node-version`
- [ ] Push to GitHub
- [ ] Import project in Vercel
- [ ] Add `ENABLE_EXPERIMENTAL_COREPACK=1` env var
- [ ] Add `NEXT_PUBLIC_WALLETCONNECT_PROJECT_ID`
- [ ] Add other environment variables
- [ ] Trigger deployment
- [ ] Visit deployed URL

## 🌐 Custom Domain (Optional)

After successful deployment:
1. Go to **Settings** → **Domains**
2. Add your custom domain
3. Follow DNS configuration instructions

## 📊 Performance Optimization

Vercel automatically handles:
- ✅ Edge caching
- ✅ Image optimization (Next.js)
- ✅ Serverless functions
- ✅ CDN distribution
- ✅ Analytics

## 🔒 Security

Vercel provides:
- ✅ Automatic HTTPS
- ✅ DDoS protection
- ✅ Environment variable encryption
- ✅ Preview deployments (safe testing)

## 💡 Alternative Deployment Options

If Vercel continues to have issues:

### Netlify:
```bash
npm i -g netlify-cli
netlify deploy --prod
```

### Railway:
```bash
# Install Railway CLI
npm i -g @railway/cli

# Login and deploy
railway login
railway up
```

### Docker + Cloud Run:
```bash
docker build -t qentifi-web .
docker push gcr.io/your-project/qentifi-web
gcloud run deploy qentifi-web --image gcr.io/your-project/qentifi-web
```

---

**Need help?** Check the main [DEPLOYMENT.md](./DEPLOYMENT.md) for detailed instructions.
