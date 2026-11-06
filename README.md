# FASAS Digitale — versione Cloud/Web

Portale web per la gestione del Fascicolo Socio Assistenziale Sanitario di una comunità.
Questa repository contiene la **versione destinata all'hosting cloud**, accessibile da browser e smartphone.

- **Sito previsto:** [fasas.online](https://fasas.online) (attivazione DNS e hosting ancora da completare).
- **Codice di sviluppo e versione installabile in locale:** [ambrogiocorti/fasas](https://github.com/ambrogiocorti/fasas).
- **Branch di rilascio:** `main`. Aggiornare solo dopo i controlli e il collaudo.

> **Attenzione:** il software è ancora in fase pilota. Non caricare informazioni sanitarie reali prima
> delle verifiche indipendenti di sicurezza, degli adempimenti privacy e della validazione clinica.

## Cosa contiene questa repository

| Componente | Funzione |
| --- | --- |
| `fasas/`, `config/`, `templates/`, `static/` | Backend Django, API e interfaccia web |
| `Dockerfile`, `docker/cloud.sh`, `docker/entrypoint.sh` | Avvio cloud in un container |
| `render.yaml` | Configurazione del servizio Render, regione UE |
| `supabase/migrations/` | Schema PostgreSQL e protezione dei dati |
| `.env.cloud.example` | Elenco delle variabili da configurare **nel servizio di hosting** |
| `.github/workflows/ci.yml` | Test del portale, sicurezza e collaudo cloud |
| `docs/CLOUD.md` | Guida completa per pubblicazione e collegamento al dominio |

Non sono distribuiti qui il server locale con Docker Compose, gli script per l'installazione su PC,
la configurazione di VPN/UPS/dischi USB, né i progetti nativi FASAS Signer per Android, iOS e desktop.
Questi restano nella [repository di sviluppo](https://github.com/ambrogiocorti/fasas).

## Architettura

```text
Browser / smartphone
        |
     HTTPS
        |
    fasas.online
        |
Render (Django + Gunicorn + pianificatore integrato)
        |
Supabase in UE (PostgreSQL + Storage privato)
```

Il backend Python **non può essere eseguito da GitHub Pages**: GitHub conserva il codice, Render
esegue il servizio web e Supabase ospita database e documenti cifrati.

## Pubblicazione cloud

Seguire [docs/CLOUD.md](docs/CLOUD.md) nell'ordine:

1. Creare un progetto Supabase in una regione UE, riservato al FASAS.
2. Applicare le migrazioni SQL e verificare la chiusura delle API di Supabase.
3. Creare il bucket privato `fasas-documenti` e predisporre i backup cifrati fuori sede.
4. In Render, creare un **Blueprint** collegato a questa repository e al branch `main`.
5. Inserire i segreti e le credenziali solamente nelle variabili di ambiente di Render,
   facendo riferimento a [`.env.cloud.example`](.env.cloud.example). Non salvarli su GitHub.
6. Associare il dominio `fasas.online` a Render e configurare i record DNS presso il registrar.
7. Verificare HTTPS, pagina `/salute/`, login, 2FA, allegati, audit e backup usando **solo dati inventati**.

Il file `render.yaml` disabilita il deploy automatico: per ogni nuova versione, eseguire il deploy
manuale dopo che i test di GitHub Actions sono passati.

## Sicurezza e requisiti prima dell'uso reale

- Nessun file `.env`, password di database, chiave di cifratura o dato di ospiti deve essere committato.
- Database, backup, file e permessi vanno verificati realmente sul servizio cloud scelto.
- Conservare fuori dal provider una copia sicura delle chiavi `FASAS_ENCRYPTION_KEYS` e `FASAS_BACKUP_KEY`.
- Completare gli [adempimenti prima dell'avvio](docs/ADEMPIMENTI_PRIMA_DELL_AVVIO.md):
  DPIA, accordi con i fornitori, test di sicurezza esterno, pilota con dati fittizi e validazione clinica.

Le guide sull'installazione fisica sono consultabili soltanto nella repository `fasas`.

## Documentazione utile

- [Guida cloud e configurazione del dominio](docs/CLOUD.md)
- [Architettura dell'applicazione](docs/ARCHITETTURA.md)
- [Backup e ripristino](docs/BACKUP.md)
- [Sicurezza](docs/SICUREZZA.md)
- [Monitoraggio](docs/MONITORAGGIO.md)
- [Roadmap e limiti della versione pilota](docs/ROADMAP.md)
