from socket import socket, AF_UNIX
import argparse


def send_command(command):
    s = socket(family=AF_UNIX)
    s.connect("/tmp/pomodoro.sock")
    s.send(command.encode())
    print(s.recv(4096).decode("utf-8"))


def start(args):
    command = f"start {args.duration}"
    send_command(command)


def stop(args):
    send_command("stop")


def pause(args):
    send_command("pause")


def resume(args):
    send_command("resume")


def status(args):
    send_command("status")


def main():
    parser = argparse.ArgumentParser()
    subparsers = parser.add_subparsers()

    start_parser = subparsers.add_parser("start")
    start_parser.add_argument("duration", type=int)
    start_parser.set_defaults(func=start)

    stop_parser = subparsers.add_parser("stop")
    stop_parser.set_defaults(func=stop)

    pause_parser = subparsers.add_parser("pause")
    pause_parser.set_defaults(func=pause)

    resume_parser = subparsers.add_parser("resume")
    resume_parser.set_defaults(func=resume)

    status_parser = subparsers.add_parser("status")
    status_parser.set_defaults(func=status)

    args = parser.parse_args()
    args.func(args)


if __name__ == "__main__":
    main()
