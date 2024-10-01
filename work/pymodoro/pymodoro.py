from socket import socket, AF_UNIX
import argparse


def send_command(command):
    s = socket(family=AF_UNIX)
    s.connect("/tmp/pomodoro.sock")
    s.send(command.encode())
    print(s.recv(4096).decode("utf-8"))


def start(args):
    digits = []
    units = ["h", "m", "s"]
    largest = None
    total = 0
    for token in args.duration_spec:
        if token.isdigit():
            digits.append(token)
        elif token in units:
            if largest and units.index(token) <= units.index(largest):
                print(
                    f"Error: Larger unit ({token}) can't follow smaller unit ({largest})!"
                )
                exit()
            largest = token
            if not digits:
                print(f"Error: No duration specified for unit ({token})!")
                exit()
            duration = int("".join(digits))
            digits.clear()
            if token == "h":
                duration *= 3600
            elif token == "m":
                duration *= 60
            total += duration
        else:
            print(f"Error: Invalid token in duration spec ({token})!")
            exit()
    if digits:
        print(f"Error: Missing unit!")
        exit()
    command = f"start {total}"
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
    start_parser.add_argument("duration_spec")
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
