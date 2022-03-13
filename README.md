# rt-nonself

Non-self / WireGuard routing tool.

## Install

As `root`:

```sh
apt install -y git
cd /opt
git clone https://github.com/vjagaro/rt-nonself.git
cd rt-nonself
./rt config
```

Review and edit `rt.conf`. Then:

```sh
./rt install
```

## Usage

```
Usage: ./rt <COMMAND> ...

  ./rt client create       Create a new client
  ./rt client list         List clients
  ./rt client qrcode <N>   Show QR code for client N
  ./rt client remove <N>   Remove client N
  ./rt client update <N>   Update client N
  ./rt config              Create rt.conf
  ./rt install             Install
```
