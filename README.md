# PasswordManager
A simple command line password manager that utilizes the encryption functions of MCrypt.

## Dependencies
PasswordManager depends on the following packages:

- mcrypt
- xsel

### Usage
```
usage: pwm [ACTION]

ACTIONS
   put  <entry name>  Insert a new entry with a new random password
   get  <entry name>  Get a particular password copied to clipboard
```

### Configuration
Just add `pwm.sh` to your `/etc/profile.d/` directory.

