# FASAS Digitale — distribuzione web

Portale web per la gestione del Fascicolo Socio Assistenziale Sanitario di una comunità.
Questa repository contiene la **distribuzione per il dominio pubblico**: il FASAS gira su un server cloud
ed è utilizzabile da browser su PC, tablet e smartphone. **Le funzionalità sono le stesse della versione locale**:
cartelle, registro, farmaci, PAI, firme digitali, CIE, app FASAS Signer per Android/iPhone e programma Signer desktop.
Cambiano soltanto avvio, indirizzo, database e archiviazione necessari all'hosting.

- **Indirizzo di produzione:** [fasas.online](https://fasas.online). Attualmente il dominio mostra questa
  documentazione tramite GitHub Pages: **non è ancora il FASAS in esecuzione**. Dopo aver attivato Render,
  i record DNS presso Register dovranno puntare a Render anziché a GitHub Pages.
- **Codice di sviluppo e versione installabile in locale:** [ambrogiocorti/fasas](https://github.com/ambrogiocorti/fasas).
- **Branch di rilascio:** `main`. Aggiornare solo dopo i controlli e il collaudo.

> **Attenzione:** il software è ancora in fase pilota. Non caricare informazioni sanitarie reali prima
> delle verifiche indipendenti di sicurezza, degli adempimenti privacy e della validazione clinica.

## Cosa contiene questa repository

| Componente | Funzione |
| --- | --- |
| `fasas/`, `config/`, `templates/`, `static/` | Backend Django, API e interfaccia web |
| `mobile/android/`, `mobile/ios/` | App FASAS Signer per firmare con CIE dal telefono |
| `signer/` | FASAS Signer per Windows, macOS e Linux con lettore CIE |
| `Dockerfile`, `docker/cloud.sh`, `docker/entrypoint.sh` | Avvio cloud in un container |
| `render.yaml` | Servizio scelto: Render, regione UE |
| `supabase/migrations/` | Schema PostgreSQL e protezione dei dati |
| `.env.cloud.example` | Elenco delle variabili da configurare **nel servizio di hosting** |
| `.github/workflows/ci.yml`, `.github/workflows/mobile.yml` | Test del portale, sicurezza, cloud e build delle app |
| `docs/CLOUD.md` | Guida completa per pubblicazione e collegamento al dominio |

Soltanto l'**infrastruttura per installare il server FASAS in locale** (Docker Compose locale, avviatori `.bat`/`.sh`,
preparazione del PC in struttura e gestione dei suoi dischi/UPS) resta nella
[repository locale](https://github.com/ambrogiocorti/fasas). I dispositivi Signer, invece, sono disponibili
in entrambe le repository: per la versione web vanno abbinati a `https://fasas.online/`.

## Architettura

```text
Browser / smartphone
        |
     HTTPS
        |
    fasas.online
        |
Render (Django + Gunicorn + pianificatore)
        |
Supabase in UE (PostgreSQL + Storage privato)

App FASAS Signer (Android/iOS/desktop) ──HTTPS──▶ fasas.online/api/firma/v1/
```

Il backend Python **non può essere eseguito da GitHub Pages**. **Render** esegue FASAS;
**Supabase** conserva dati e documenti; **Register** gestisce i DNS del dominio; **GitHub Pages** rimane
per la documentazione pubblica sul dominio GitHub (`ambrogiocorti.github.io/fasas-deploy/`), senza dati sanitari.
Il portale e le API, escluso il controllo tecnico `/salute/`, rifiutano le richieste al dominio tecnico dell'hosting:
sono accessibili su **`fasas.online`**.

## Pubblicazione cloud

Seguire [docs/CLOUD.md](docs/CLOUD.md) nell'ordine:

1. Creare un progetto Supabase in una regione UE, riservato al FASAS.
2. Applicare le migrazioni SQL e verificare la chiusura delle API di Supabase.
3. Creare il bucket privato `fasas-documenti` e predisporre i backup cifrati fuori sede.
4. In Render creare un **Blueprint** da `main`.
5. Inserire i segreti e le credenziali solamente nelle variabili di ambiente dell'hosting,
   facendo riferimento a [`.env.cloud.example`](.env.cloud.example). Non salvarli su GitHub.
6. Associare `fasas.online` a Render e sostituire in **Register** i record DNS che ora puntano a
   GitHub Pages con quelli indicati da Render. **Dopo aver verificato il portale su Render**, rimuovere
   `fasas.online` come dominio personalizzato di GitHub Pages e il file `CNAME`, mantenendo Pages attivo
   sull'indirizzo GitHub per la sola documentazione.
7. Verificare HTTPS, pagina `/salute/`, login, 2FA, allegati, audit e backup usando **solo dati inventati**.

Il file `render.yaml` disabilita il deploy automatico: per ogni nuova versione, eseguire il deploy
manuale dopo che i test di GitHub Actions sono passati.

La firma CIE non viene eseguita direttamente dal browser: richiede FASAS Signer e la configurazione dei
certificati CIE sul server. Le app non sono state ancora collaudate integralmente con CIE reali.

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
