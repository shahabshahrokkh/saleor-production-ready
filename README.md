# Saleor E-Commerce Platform - Production Ready

A complete, production-ready e-commerce platform based on Saleor with full source code for API, Storefront, and Dashboard.

## ðŸš€ Features

- **Complete Source Code**: API (Django/GraphQL), Storefront (Next.js), Dashboard (React)
- **Production Ready**: Docker Compose setup with Nginx, PostgreSQL, Redis
- **Fully Customizable**: Modify any part of the system
- **Modern Stack**: Python 3.12, TypeScript, React, Next.js 15

## ðŸ“¦ Components

### 1. API (Backend)
- **Location**: \saleor/\
- **Tech**: Python 3.12 + Django + GraphQL
- **Features**: Products, Orders, Payments, Webhooks, Plugins

### 2. Storefront (Customer-facing)
- **Location**: \storefront-main/\
- **Tech**: TypeScript + Next.js 15 + React
- **Features**: Product browsing, Cart, Checkout, User accounts

### 3. Dashboard (Admin Panel)
- **Location**: \dashboard-main/\
- **Tech**: TypeScript + React + Vite
- **Features**: Product management, Order management, Customer management

## ðŸ› ï¸ Quick Start

### Prerequisites
- Docker & Docker Compose
- Git

### Installation

1. **Clone the repository**
\\\ash
git clone <your-repo-url>
cd saleor-production-ready
\\\

2. **Setup environment**
\\\ash
cd production
cp .env.example .env
# Edit .env and set your secrets
\\\

3. **Start all services**
\\\ash
docker compose up -d --build
\\\

4. **Access the services**
- Storefront: http://localhost:3000
- Dashboard: http://localhost:9001
- API: http://localhost:8000/graphql/

## ðŸ“š Documentation

- [\ARCHITECTURE.md\](ARCHITECTURE.md) - System architecture
- [\PROJECT_STATUS.md\](PROJECT_STATUS.md) - Project status and capabilities
- [\SETUP_GUIDE_FA.md\](SETUP_GUIDE_FA.md) - Persian setup guide
- [Official Saleor Docs](https://docs.saleor.io/)

## ðŸ”§ Development

### API Development
\\\ash
# Make changes in saleor/
docker compose restart api
\\\

### Storefront Development
\\\ash
# Make changes in storefront-main/src/
# Hot reload is automatic
\\\

### Dashboard Development
\\\ash
# Make changes in dashboard-main/src/
# Hot reload is automatic
\\\

## ðŸŒ Production Deployment

### Security Checklist
- [ ] Change \SECRET_KEY\ in \.env\
- [ ] Generate \RSA_PRIVATE_KEY\ for JWT
- [ ] Set \DEBUG=False\
- [ ] Configure proper \ALLOWED_HOSTS\
- [ ] Setup SSL/TLS certificates
- [ ] Configure backup strategy
- [ ] Setup monitoring (Sentry, etc.)

### Environment Variables
See \production/.env.example\ for all available options.

## ðŸ“ License

See [LICENSE](LICENSE) file.

## ðŸ¤ Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for contribution guidelines.

## ðŸ“§ Support

- [Saleor Documentation](https://docs.saleor.io/)
- [Saleor Community](https://github.com/saleor/saleor/discussions)

---

**Built with â¤ï¸ using Saleor**
