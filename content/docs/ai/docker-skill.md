---
title: 'Docker Skill: Optimizing Dockerfiles for Performance and Efficiency'
description: AI Skill for optimizing Dockerfiles, including best practices for reducing image size and improving build performance.
version: '1.0'
categories: [AI]
tags: [AI, skills, productivity]
date: '2026-03-25T08:00:00+01:00'
lastmod: '2026-03-25T08:00:00+01:00'
---

This [AI Docker Skill](https://github.com/fchastanet/copilot-prompts/blob/master/skills/fc-optimize-dockerfile/SKILL.md)
provides personalized recommendations for optimizing your Docker images and improving build performance using an AI
Copilot Agent. It covers various aspects of Dockerfile optimization, including:

- Using multi-stage builds to reduce image size
- Choosing the right base image for your application
- Minimizing the number of layers in your Dockerfile
- Leveraging caching effectively to speed up builds
- Implementing best practices for security and maintainability

Example of transforming a Dockerfile using the AI Docker Skill:

```Dockerfile
# Original Dockerfile
FROM node:20-alpine
WORKDIR /app
COPY package.json ./
RUN npm install
COPY . .
RUN npm run build
CMD ["npm", "start"]
```

## 1. Q&A with AI

**I asked** AI using Docker Skill with `Claude Sonnet 4.5` AI Model:

**Here Q&A with AI:**

> Do you want a development stage for local development with hot-reloading and dev dependencies?

Yes - Include dev stage with hot-reload support

> Should the Dockerfile include a test stage for running unit tests, integration tests, or pre-commit hooks?

Yes - Run tests during build

> Do you want security scanning (Trivy, Snyk, etc.) integrated into the build process?

No - Skip security scanning

> Should images be signed for verification (using Cosign, Notary, or Docker Content Trust)?

No - Skip image signing

> What are the deployment environments? Local - Local development, Staging - Staging environment,

Production - Production environment

> Are there specific base image requirements?

node:20-slim - Recommended: Debian-based minimal image

> Do you want advanced image size optimization (adds complexity)?

NPM cache optimization - Disable npm cache

## 2. Resulting Dockerfile

**Result**: AI automatically generates the optimized Dockerfile based on the provided answers:

```Dockerfile
# =============================================================================
# Stage Diagram:
#
# base (node:20-slim)
# ├─> development (with hot-reload, dev dependencies)
# ├─> dependencies (production dependencies only)
# │     └─> build (compile application)
# │           └─> test (run tests, validation)
# │                 └─> production (minimal runtime image)
#
# =============================================================================

# =============================================================================
# Stage: base
# Purpose: Common base configuration for all stages
# =============================================================================
FROM node:20-slim AS base
SHELL ["/bin/bash", "-o", "pipefail", "-o", "errexit", "-o", "xtrace", "-c"]

# Environment Variables - Build-time Configuration
# Description: Prevent interactive prompts during apt operations
# Required: Yes (for automated builds)
ARG DEBIAN_FRONTEND=noninteractive

# Environment Variables - Runtime Configuration
# Description: Node environment (development, staging, production)
# Default: production
# Example: development, staging, production
# Required: No
ENV NODE_ENV=production

# Description: Enable verbose logging for debugging
# Default: false
# Example: true, false
# Required: No
ENV DEBUG=false

# Description: Application port for the Node.js server
# Default: 3000
# Example: 3000, 8080
# Required: No
ENV PORT=3000

# Description: Prevent npm from creating package-lock updates
# Default: off
# Required: No
ENV NPM_CONFIG_UPDATE_NOTIFIER=off

# Description: Disable npm cache to reduce image size
# Default: false
# Example: true (for production), false (for dev)
# Required: No
ENV NPM_CONFIG_CACHE=/tmp/npm-cache

WORKDIR /app

# Install security updates and minimal system dependencies
# If you need an IMMUTABLE IMAGE, comment out the upgrade
RUN <<EOF
apt-get update
apt-get upgrade -y
apt-get install -y -q --no-install-recommends \
  'ca-certificates=20*' \
  'curl=7.*' \
  'tini=0.19.*'
apt-get autoremove -y
apt-get clean
rm -rf /var/lib/apt/lists/* /var/cache/apt/archives /tmp/* /var/tmp/* /usr/share/{doc,man,locale}/
EOF

# =============================================================================
# Stage: development
# Purpose: Development environment with hot-reload and dev tools
# =============================================================================
FROM base AS development
SHELL ["/bin/bash", "-o", "pipefail", "-o", "errexit", "-o", "xtrace", "-c"]

ENV NODE_ENV=development
ENV NPM_CONFIG_CACHE=/home/node/.npm

# Copy dependency files for caching optimization
COPY --chown=node:node package*.json ./

# Install ALL dependencies (including devDependencies)
RUN <<EOF
npm ci
npm cache clean --force
EOF

# Copy source code
COPY --chown=node:node . .

USER node

EXPOSE 3000

# Health check for development
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:3000/health || exit 1

# Use nodemon or npm run dev for hot-reload (adjust based on your package.json)
CMD ["npm", "run", "dev"]

# =============================================================================
# Stage: dependencies
# Purpose: Install production dependencies only (optimized caching)
# =============================================================================
FROM base AS dependencies
SHELL ["/bin/bash", "-o", "pipefail", "-o", "errexit", "-o", "xtrace", "-c"]

# Copy dependency files for caching optimization
COPY package*.json ./

# Install production dependencies only (no dev dependencies)
RUN <<EOF
npm ci --only=production --no-cache
npm cache clean --force
EOF

# =============================================================================
# Stage: build
# Purpose: Build the application from source
# =============================================================================
FROM base AS build
SHELL ["/bin/bash", "-o", "pipefail", "-o", "errexit", "-o", "xtrace", "-c"]

# Copy dependency files for caching optimization
COPY package*.json ./

# Install ALL dependencies (including devDependencies for build)
RUN <<EOF
npm ci --no-cache
npm cache clean --force
EOF

# Copy source code
COPY . .

# Build the application
RUN <<EOF
npm run build
EOF

# =============================================================================
# Stage: test
# Purpose: Run tests to validate the build
# =============================================================================
FROM build AS test
SHELL ["/bin/bash", "-o", "pipefail", "-o", "errexit", "-o", "xtrace", "-c"]

# Run tests (adjust command based on your package.json)
RUN <<EOF
npm run test
touch /tmp/tests-passed
EOF

# =============================================================================
# Stage: production
# Purpose: Minimal production runtime image
# =============================================================================
FROM base AS production
SHELL ["/bin/bash", "-o", "pipefail", "-o", "errexit", "-o", "xtrace", "-c"]

# Create non-root user with specific UID/GID for security
RUN <<EOF
groupadd -r -g 1001 appuser
useradd -r -u 1001 -g appuser -s /sbin/nologin -c "Application User" appuser
mkdir -p /app/logs /app/tmp
chown -R appuser:appuser /app
EOF

# Copy production dependencies from dependencies stage
COPY --from=dependencies --chown=appuser:appuser /app/node_modules ./node_modules

# Copy built application from build stage
COPY --from=build --chown=appuser:appuser /app/dist ./dist
COPY --from=build --chown=appuser:appuser /app/package*.json ./

# Copy test marker to ensure tests passed
COPY --from=test /tmp/tests-passed /tmp/tests-passed

# Switch to non-root user
USER appuser

# Document exposed port
EXPOSE 3000

# Health check for production
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
  CMD curl -f http://localhost:${PORT}/health || exit 1

# Use tini as init system for proper signal handling
ENTRYPOINT ["/usr/bin/tini", "--"]

# Start the application
CMD ["node", "dist/index.js"]
```

## 3. Review Comments

During the process, AI automatically generates a package.jso in order to be able to build the image and test it.

The resulting Dockerfile is optimized for both development and production environments, with separate stages for
dependencies, build, testing, and production runtime. It incorporates best practices for image size reduction, caching
optimization, security hardening, and maintainability.

But **Never trust AI blindly** - Always review the generated Dockerfile and test it thoroughly to ensure it meets your
specific requirements and follows best practices for your application.

Anyway here my review comments about this generated Dockerfile:

- The `COPY --chown=node:node . .` in development stage is not necessarily because most of the time we are mounting the
  source code in development.
- `USER node` in development stage is hard to use because of the permissions issues when mounting volumes, we should use
  root user in development stage.
- The stage inheritance is wrong while the dependency schema at the beginning of the Dockerfile has not been respected:
  - the build stage is inheriting from base and use npm ci in development mode
  - The production stage inherit from base but copy the node_modules from dependencies stage (it is why AI puts this
    wrong inheritance)
  - as only production stage need the dependencies, it is better to have the RUN npm ci --only=production in the
    production stage-

a clearer diagram could be:

```Dockerfile
# =============================================================================
# Stage Diagram:
#
# base (node:20-slim)
# ├─> development (with hot-reload, dev dependencies)
# ├─> dependencies (production dependencies only)
# ├─> build (compile application)
# │     └─> test (run tests, validation)
# └─> production (minimal runtime image)
# <-- depends on (dependencies, build, test)
#
# =============================================================================
```

## 4. Conclusion

OK I agree it is more complex to read but it is more optimized and secured that the original one.

Stay tuned as I will continuously improve this skill with new features and optimizations based on the latest Docker best
practices and user feedback!

📢 What do you think about this generated Dockerfile? Do you have any 💡 feedbacks ? Let me know in the 💬 comments!
