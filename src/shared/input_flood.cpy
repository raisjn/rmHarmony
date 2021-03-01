#include <linux/input.h>
#include <cstring>

namespace flood:
  int touch_flood_size = 0
  static input_event *touch_flood
  static input_event *button_flood

  input_event* build_touch_flood():
    n := 512 * 8
    touch_flood_size = n
    input_event *ev = (input_event*) malloc(sizeof(struct input_event) * n)
    memset(ev, 0, sizeof(input_event) * n)

    i := 0
    j := input::TouchEvent::MAX_SLOTS

    num_inst := 4 // instructions
    ending := 4 // instructions
    while i + 4 < n - num_inst*input::TouchEvent::MAX_SLOTS - ending:
      ev[i++] = input_event{ type:EV_ABS, code:ABS_DISTANCE, value:1 }
      ev[i++] = input_event{ type:EV_SYN, code:0, value:0 }
      ev[i++] = input_event{ type:EV_ABS, code:ABS_DISTANCE, value:2 }
      ev[i++] = input_event{ type:EV_SYN, code:0, value:0 }

    for j := 0; j < input::TouchEvent::MAX_SLOTS; j++:
      ev[i++] = input_event{ type:EV_ABS, code:ABS_MT_SLOT, value: j }
      ev[i++] = input_event{ type:EV_ABS, code:ABS_DISTANCE, value: 3 }
      ev[i++] = input_event{ type:EV_ABS, code:ABS_MT_TRACKING_ID, value: -1 }
      ev[i++] = input_event{ type:EV_SYN, code:0, value:0 }

    ev[i++] = input_event{ type:EV_SYN, code:0, value:0 }
    ev[i++] = input_event{ type:EV_ABS, code:ABS_MT_SLOT, value: 0 }
    ev[i++] = input_event{ type:EV_ABS, code:ABS_MT_TRACKING_ID, value: -1 }
    ev[i++] = input_event{ type:EV_ABS, code:ABS_DISTANCE, value: 10  }



    touch_flood = ev
    return ev

  input_event* build_button_flood():
    n := 512 * 8
    num_inst := 2
    input_event *ev = (input_event*) malloc(sizeof(struct input_event) * n * num_inst)
    memset(ev, 0, sizeof(input_event) * n * num_inst)

    i := 0
    while i < n:
      ev[i++] = input_event{ type:EV_SYN, code:1, value:0 }
      ev[i++] = input_event{ type:EV_SYN, code:0, value:1 }

    button_flood = ev
    return ev



  void flood_touch_queue():
    fd := ui::MainLoop::in.touch.fd
    bytes := write(fd, touch_flood, touch_flood_size * sizeof(input_event))

    ui::MainLoop::reset_gestures()

  // TODO: figure out the right events here to properly flood this device
  void flood_button_queue():
    fd := ui::MainLoop::in.button.fd
    bytes := write(fd, button_flood, 512 * 8 * 2 * sizeof(input_event))
