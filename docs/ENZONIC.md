# Collaudo FASAS su Enzonic Cloud (senza carta)

Questa guida riguarda **esclusivamente un ambiente di prova con dati fittizi**.
Il progetto di sviluppo locale in `ambrogiocorti/fasas` non va modificato.
Si usa il server Django completo di `ambrogiocorti/fasas-deploy`, comprese API, firma digitale,
file cifrati e scheduler. Il provider deve ancora essere collaudato: non dichiarare FASAS pronto
per una comunità finché tutti i controlli elencati sotto non siano superati.

## 1. Scelta del prodotto corretto

Nel pannello https://panel.enzonic.com/ scegliere **Python generic** (server persistente),
non Enzonic Deploy: il secondo prodotto in modalità gratuita può sospendere il processo e,
secondo il sito del provider, viene eseguito negli Stati Uniti.

- Piano: **Free**, senza metodo di pagamento, soltanto se realmente disponibile.
- RAM: almeno 512 MB; impostare **1 worker Gunicorn** e **2 thread** per le prime prove.
- Regione: **Spain** o altra regione UE effettivamente disponibile.
- Sorgente: repository pubblico `https://github.com/ambrogiocorti/fasas-deploy`.
- Python: **3.12**.
- Porta HTTP: usare la porta assegnata da Enzonic (`SERVER_PORT`, altrimenti impostare `PORT`).
- File principale Python: `main.py`; avvia `scripts/avvia_enzonic.sh` tramite l'interprete Python.
- Installazione da Git: disabilitare **User Uploaded Files**, inserire la repository Git e il branch `main`.

Non modificare ancora il DNS. Se il piano gratuito non consente un dominio personale,
interrompere la configurazione del dominio e valutarne l'alternativa prima di procedere.

## 2. Installazione e variabili

Il file `requirements.txt` richiama `requirements.lock`: l'installazione automatica
di Enzonic usa così versioni e hash bloccati. Se l'installazione automatica non parte,
eseguire dalla console `python -m pip install --require-hashes -r requirements.lock`.
Non inserire mai password o chiavi nel repository o nei comandi visibili nei log.

Nell'area dedicata alle **variabili d'ambiente protette**, inserire le variabili di
`.env.cloud.example`; quelle obbligatorie sono:

- `DJANGO_SECRET_KEY`, `FASAS_ENCRYPTION_KEYS`, `FASAS_BACKUP_KEY` (generare chiavi
  casuali diverse; custodire copie offline in modo sicuro).
- `DATABASE_URL` (Supabase Connect › **Session pooler**, porta **5432**, non la connessione diretta IPv6).
- `DATABASE_SSL_REQUIRE=1`.
- `FASAS_S3_BUCKET=fasas-documenti` e tutti i `FASAS_S3_*` (chiavi **S3 server** di Supabase, non `service_role`).
- `FASAS_OFFSITE_BUCKET=fasas-backup`, `FASAS_OFFSITE_LOCK_DAYS=0` e tutti i
  `FASAS_OFFSITE_*` richiesti dalla guida cloud.
- `FASAS_ADMIN_USERNAME` e `FASAS_ADMIN_PASSWORD` per creare il primo utente di prova.
- `PORT` con la porta assegnata dal pannello Enzonic, se non è già disponibile come `SERVER_PORT`.
- `FASAS_DOMAIN` con **il solo host su cui si sta facendo il test**. Per il collaudo su
  un sottodominio temporaneo, impostare temporaneamente tale host; prima dell'apertura
  del sito definitivo riportare il valore a `fasas.online`.

Il progetto Supabase FASAS attuale è nella regione `eu-west-1` (Irlanda).
L'endpoint S3 segue il formato `https://<project-ref>.storage.supabase.co/storage/v1/s3`.
La regione S3 è `eu-west-1`, non `eu-central-1` come negli esempi generici di Render.

La migrazione SQL del progetto vuoto avviene all'avvio tramite Django. Verificare che
le tabelle siano protette da RLS e senza privilegi API: **nessun accesso diretto
alle cartelle cliniche tramite Data API Supabase**.

## 3. Verifiche obbligatorie prima di aprire il dominio

1. L'avvio deve completare `migrate`, la creazione dell'admin e `fasas_pianificatore`.
2. `GET /salute/` deve rispondere correttamente e il server deve rimanere acceso.
3. Un utente deve poter accedere, completare la 2FA e visualizzare la dashboard.
4. Creare un **ospite inventato**, aggiungere parametri e un documento fittizio,
   scaricarlo e controllare che il bucket Supabase non sia pubblico.
5. Verificare che la firma digitale e le API per i firmatari siano raggiungibili;
   il collaudo di una firma CIE reale richiede dispositivo e carta reali.
6. Verificare `pg_dump --version`: deve essere **17 o superiore**, perché Supabase
   usa PostgreSQL 17. Senza questo binario il sito può aprirsi, ma il backup e
   il ripristino completo **non possono essere dichiarati funzionanti**.
7. Eseguire un backup di prova, verificarne cifratura, copia nel bucket
   `fasas-backup` e **prova effettiva di ripristino su un database di test separato**.
8. Verificare i log di accesso, l'audit, la scadenza delle sessioni e i job pianificati.
9. Verificare la RAM sotto carico (512 MB potrebbero non bastare) e il comportamento
   dopo un riavvio del server, senza perdere dati e chiavi.

Solo dopo queste verifiche, confermare la disponibilità del dominio personalizzato
nel piano scelto, aggiungerlo sul provider, copiare **esattamente** i record DNS che
il pannello indica nel dominio Register, aspettare HTTPS e togliere da GitHub Pages
il dominio `fasas.online` (lasciando Pages per i manuali).

## Avvertenza per dati sanitari reali

Il piano gratuito serve unicamente a prove con dati sintetici. Prima dell'uso nella
comunità serve anche approvazione dell'ente, verifica dei fornitori e DPA (art. 28 GDPR),
DPIA, regione di elaborazione e trasferimenti internazionali, disponibilità del servizio,
backup indipendenti e procedure di continuità. L'hosting gratuito non offre di per sé
le garanzie necessarie.

Per il deployment Docker su altri hosting resta valida la guida [CLOUD.md](CLOUD.md).
