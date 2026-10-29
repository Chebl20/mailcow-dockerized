# Deploy mailcow no Coolify (fork Chebl20)

Repositório: `https://github.com/Chebl20/mailcow-dockerized`  
Hostname padrão: **mail.sowtech.io**  
Branch: **master** (não `main`)

## Pré-requisitos

- VPS dedicada ao mailcow **recomendada** (portas 25/80/443/465/587/993 livres).
- Docker ≥ 24 e Docker Compose plugin (`docker compose`).
- DNS de `mail.sowtech.io` apontando para o IP da VPS antes do Let's Encrypt.

## Passo a passo no Coolify

1. **Projects** → seu projeto → **Add Resource** → **Docker Compose**.
2. Fonte **Git**: URL do fork, branch **`master`**.
3. **Base Directory**: `/` (raiz do repo).
4. **Docker Compose Location**: `docker-compose.yml`.
5. **Advanced → Docker compose → Compose deployment**: preferir **Raw (deploy file as-is)**  
   O mailcow publica portas de e-mail no host; o proxy HTTP do Coolify não substitui SMTP/IMAP.
6. **Custom Start Command** (substitui o `up` padrão):

   ```bash
   bash deploy/coolify-start.sh
   ```

7. **Environment**: copie de `deploy/coolify.env.example`. Defina segredos no Coolify como **Secret**; não commite `mailcow.conf`.
8. **Persistent storage**: monte o diretório de deploy (ou pelo menos `data/` + `mailcow.conf`) para sobreviver a redeploys Git.
9. **Deploy** e acompanhe os logs.

## O que os scripts fazem

| Script | Função |
|--------|--------|
| `deploy/coolify-ensure-config.sh` | Cria `mailcow.conf` na 1ª execução, certificado snake-oil inicial, placeholders rspamd. |
| `deploy/coolify-start.sh` | `ensure-config` → `docker compose --env-file mailcow.conf pull` → `up -d`. |

O `generate_config.sh` oficial é **interativo**; no Coolify use estes scripts.

## Mesma VPS do Coolify vs VPS separada

| Cenário | Recomendação |
|---------|----------------|
| **VPS só para mailcow** | Portas padrão 80/443/25/… no host. Sem domínio HTTP no Coolify para o stack. |
| **Coolify + mailcow na mesma VPS** | Conflito em **80/443** com Traefik. Opções: VPS separada **ou** alterar `HTTP_PORT`/`HTTPS_PORT` e seguir [reverse proxy mailcow](https://docs.mailcow.email/post_installation/reverse-proxy/r_p/). |

## Atualizações

- **Git push no fork** atualiza arquivos do repo; **não** substitui o fluxo `./update.sh` do mailcow para imagens e migrações.
- Para upgrades oficiais: SSH na VPS, `cd` no diretório de deploy, `./update.sh`.
- Desative webhook de auto-deploy se não quiser `git pull` + `compose up` a cada push.

## Após o deploy

1. DNS: `A`/`AAAA` para `mail.sowtech.io`, MX, SPF, DKIM (UI mailcow), DMARC.
2. UI: `https://mail.sowtech.io/admin` — usuário padrão `admin` / senha `moohoo` (**altere na 1ª login**).
3. Valide SMTP, IMAP, TLS e envio externo.

## Referências

- [mailcow-dockerized](https://github.com/mailcow/mailcow-dockerized)
- [Documentação mailcow](https://docs.mailcow.email/)
- [Coolify — Docker Compose](https://coolify.io/docs/applications/builds/docker-compose)
