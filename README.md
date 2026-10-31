# Mac Bootstrap

Ein kleines Startskript für macOS. Persönliche Dotfiles und Paketlisten bleiben
in einem separaten, privaten GitHub-Repository.

## Starten

Im Terminal herunterladen und starten:

```sh
curl -fsSLo mac-bootstrap.sh https://raw.githubusercontent.com/Flipp-io/mac-bootstrap/main/bootstrap.sh
bash mac-bootstrap.sh
```

Das Skript fragt nach dem Repository als `OWNER/REPO`. Alternativ direkt angeben:

```sh
bash mac-bootstrap.sh OWNER/dotfiles work
# oder: personal statt work
```

## Ablauf

1. Apple Command Line Tools prüfen. Falls sie fehlen: Installation im
   macOS-Dialog abschließen und das Skript erneut starten.
2. Homebrew und die GitHub CLI bei Bedarf installieren.
3. Bei GitHub im Browser anmelden, sofern noch keine CLI-Anmeldung besteht.
4. Das angegebene Repo nach `~/dotfiles` klonen und dessen `install.sh` starten.

Der GitHub-Account muss Zugriff auf das Dotfiles-Repo haben. Dieses muss eine
`install.sh` enthalten, die optional `work` oder `personal` als Argument annimmt.
Ohne Profil übernimmt der Dotfiles-Installer die Auswahl.

Als normaler Benutzer starten. Einzelne Installationen können Administratorrechte
erfordern. Existiert `~/dotfiles` bereits, bleibt es unverändert; für weitere
Einrichtungsversuche und Updates den Installer im vorhandenen Repo verwenden.

Die GitHub CLI speichert die Anmeldung für spätere Zugriffe. Persönliche
Repository-Adressen, Konfigurationen und Zugangsdaten sind hier nicht enthalten.

## Lizenz

[MIT](LICENSE)
