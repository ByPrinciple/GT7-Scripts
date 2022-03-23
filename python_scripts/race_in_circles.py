import sys
import time
import random
import pyautogui

# Default parameters - these can be overridden with command
# line arguments. See end of script for details.
RACE_DURATION = 200
DIRECTION = "right"
SILENCE = False


def press(key: str) -> None:
    """Press a key.

    Using vanilla `pyautogui.press()` will not register the keystroke
    because GT requires you hold a keypress for a small duration."""
    with pyautogui.hold(key):
        time.sleep(0.2)


def hold(key: str, duration: float) -> None:
    """Hold a key for some duration."""

    with pyautogui.hold(key):
        time.sleep(duration)


def ride_rail(direction: str) -> None:
    """
    This will drive a car around any convex hull while hugging
    the `direction` rail. If you pass `left`, your car will hug
    the left rail, thus allowing you to go around righthand turns.
    """

    race_start = time.time()
    with pyautogui.hold("up"):
        while time.time() - race_start < RACE_DURATION:
            hold(direction, (random.randrange(200) / 1000))
            time.sleep((random.randrange(100) / 100))


def race(direction: str) -> None:
    """`direction` is the rail to hug, not the direction to turn!"""

    ride_rail(direction)


def end_race() -> None:
    """Navigate through post-race menus and replay."""

    commands = [
        "enter",
        "enter",
        "enter",
        "enter",
        "enter",
        "enter",
        "enter",
        "right",
        "enter",
        "down",
        "down",
        "down",
        "left",
        "left",
        "enter",
    ]
    for command in commands:
        press(command)
        time.sleep((random.randrange(500) / 1000) + 2)


def start_race(first: bool) -> None:
    """Initiate race from the start race menu."""
    if first:
        # Click center of screen to focus remote play window.
        # You can reposition and resize remote play window, just
        # make sure you update where you click. I don't know how to
        # use pyautogui in headless mode.
        width, height = pyautogui.size()
        center = width / 2, height / 2
        pyautogui.moveTo(center)
        pyautogui.click()
        time.sleep(1)

        # This is the button sequence you press when the 'replay'
        # button IS NOT visible on the race start screen.
        press("down")
        press("down")
        press("down")
        press("left")
        press("enter")
    else:
        # This is the button sequence you press when the 'replay'
        # button IS visible on the race start screen.
        press("down")
        press("down")
        press("down")
        press("left")
        press("left")
        press("enter")


if __name__ == "__main__":

    args = sys.argv
    for arg in args[1:]:
          if "=" in arg:
              flag, value = arg.split("=")
              if flag == "--direction":
                  DIRECTION = value
              if flag == "--duration" and value.isdigit():
                  RACE_DURATION = int(value)
          else:
              if arg == "-left" or arg == "-l":
                  DIRECTION = "left"
              if arg == "-right" or arg == "-r":
                  DIRECTION = "right"
              if arg == "-silence":
                  SILENCE = True
              if arg.isdigit():
                  RACE_DURATION = int(value)

    first = True
    while True:
        start = time.time()
        start_race(first)
        first = False
        race(DIRECTION)
        end_race()
        end = time.time()
        duration = end - start
        print(duration, flush=True)

        if not SILENCE:
            print(f"{(((60*60) / duration)):.2f} races/hour", flush=True)
