*This project has been created as part of the 42 curriculum by maria-ol.*

# Inception

## 📖 Description

*A “Description” section that clearly presents the project, including its goal and a brief overview.*

Inception is about designing a minimal production-grade architecture with strict boundaries:

- NGINX handles external communication and TLS
- WordPress handles application logic
- MariaDB handles persistent data
- Docker network handles internal communication
- Volumes handle persistence
- PID 1 defines container lifecycle

obs -> fazer um diagrama mermaid talvez pra exemplificar melhor depois


## ⚙️ Instructions

*An “Instructions” section containing any relevant information about compilation, installation, and/or execution.*

### Dependencies


### Build

```bash
<placeholder>
make
```


Other useful targets:

```bash
make clean   # remove intermediate object files
make fclean  # remove object files + binaries
make re      # fclean + all
make val     # build + run under valgrind (full leak-check)
make test    # build only the parser as a standalone binary 
```

### Running

```bash
<placeholder>
```

The program expects exactly...


## 📖 Project Description

*A Project description section must also explain the use of Docker and the sources included in the project.*

Expected boot logic:

1. mariadb starts → database initialized
2. wordpress starts → waits for DB connection
3. nginx starts → waits for wordpress upstream
4. traffic begins

*It must indicate the main design choices, as well as a comparison between:*
◦ Virtual Machines vs Docker
◦ Secrets vs Environment Variables

◦ Docker Network vs Host Network
- All containers communicate through a private virtual network created by Docker. They do not use localhost, nor physical IPs. Instead, they resolve each other by container name.
This means NGINX can reach WordPress simply using wordpress:9000, and WordPress can reach MariaDB using mariadb:3306. Docker’s embedded DNS system handles this resolution automatically.

◦ Docker Volumes vs Bind Mounts
- VOlumes: They are external storage systems attached to containers to preserve data beyond container lifecycle.

## 📁 Project Structure

Text

<details>
<summary><b>▸ Full directory tree</b></summary>

<br>

```
Inception/

```

</details>

## 🔄 Execution Flow

Texts and/or diagrams

<details>
<summary><b>▸ Full flow, from <code>argv[1]</code> to exit</b></summary>

<br>


</details>

## 🔨 Technical Overview

### Topics

Text


## 📚 Resources

*• A “Resources” section listing classic references related to the topic (documentation, articles, tutorials, etc.), as well as a description of how AI was used — specifying for which tasks and which parts of the project*

### References and documentation

- [Persistence vs Ephemerality](https://www.youtube.com/watch?v=qr3tRJGkIS4) — Ephemeral vs Persistent Storage | System Design Tradeoffs

- [Medium Article - Inception 42](https://devabdilah.medium.com/inception-42-a-comprehensive-guide-to-dockerizing-your-first-infrastructure-part-i-bd7d4bdc13e6) — A Comprehensive Guide to Dockerizing Your First Infrastructure
- [DigitalOcean](https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-on-ubuntu-20-04) — How To Install and Use Docker on Ubuntu
- [Title](Link) — Text



### AI usage

The AI assistant Claude (Anthropic), via Claude Code, was used as a pair-programming aid throughout the project, mainly for:

-

The AI did not write the logic or any scripts — those parts were implemented and debugged by hand by the student, with the AI acting as a review aid, debugging support, and study resource.
