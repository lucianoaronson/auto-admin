GUÍA DE USO – TP Final Automatización de Tareas de Administración de Sistemas (Windows & Linux)
Clonar el proyecto
git clone https://github.com/lucianoaronson/auto-admin.git
cd auto-admin

Requisitos
Sistema	Tecnología utilizada
Linux (WSL)	Bash, apt, tar
Windows	PowerShell 5+, PSWindowsUpdate
Orquestación	Ansible
1) Scripts Linux

Ubicados en linux/.

Crear Usuario Linux
chmod +x linux/users/create_user.sh
./linux/users/create_user.sh -u demo -n "Demo User" -g "sudo"

Backup Linux
chmod +x linux/backup/backup_dirs.sh
./linux/backup/backup_dirs.sh

Parches Linux
chmod +x linux/patch/patch_linux.sh
sudo ./linux/patch/patch_linux.sh

Auditoría Linux
chmod +x linux/audit/audit_logs.sh
sudo ./linux/audit/audit_logs.sh


Evidencias generadas:
docs/evidencias/*.log, docs/evidencias/backups-linux/*.tar.gz, docs/evidencias/*.csv

2) Scripts Windows

Abrir PowerShell como Administrador dentro del repo:

cd C:\Users\<USER>\Projects_Automatizacion\auto-admin
Set-ExecutionPolicy Bypass -Scope Process -Force

Crear Usuarios Windows
cd windows\users
powershell -ExecutionPolicy Bypass -File .\New-LocalUser-Bulk.ps1 -CsvPath .\users.csv
Get-LocalUser | Select Name,Enabled

Backup Windows
cd ..\backup
powershell -ExecutionPolicy Bypass -File .\Backup-Dirs.ps1
Get-ChildItem C:\Backups\auto-admin

Parches Windows
cd ..\patch
powershell -ExecutionPolicy Bypass -File .\Install-WindowsUpdates.ps1

Auditoría Windows
cd ..\audit
powershell -ExecutionPolicy Bypass -File .\Audit-EventLogs.ps1

3) ANSIBLE (Linux → WSL)

Instalación recomendada:

sudo apt update
sudo apt -y install ansible-core


Test conexión:

cd ansible
ansible -i inventory.ini all -m ping


Ejecutar automatización via Ansible:

ansible-playbook -i inventory.ini playbooks/users.yml
ansible-playbook -i inventory.ini playbooks/backup.yml
ansible-playbook -i inventory.ini playbooks/patch.yml
ansible-playbook -i inventory.ini playbooks/audit.yml

Evidencias

Todo lo generado se almacena en:

docs/evidencias/


Esta carpeta contiene outputs reales demostrables del trabajo:
logs, CSV, backups, capturas.

Rollback / Limpieza

Linux:

sudo userdel -r demo
sudo rm docs/evidencias/*.log
sudo rm docs/evidencias/backups-linux/*


Windows:

Remove-LocalUser -Name jdoe
Remove-LocalUser -Name msmith
