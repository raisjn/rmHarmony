#include <cstddef>
#include "../build/rmkit.h"
using namespace std

class App:
  public:
  ui::Scene demo_scene
  ui::Text *palm_area


  App():
    demo_scene = ui::make_scene()
    ui::MainLoop::set_scene(demo_scene)

    fb := framebuffer::get()
    fb->clear_screen()
    fb->redraw_screen()
    w, h = fb->get_display_size()

    // let's lay out a bunch of stuff

    v_layout := ui::VerticalLayout(0, 0, w, h, demo_scene)
    h_layout1 := ui::HorizontalLayout(0, 0, w, 50, demo_scene)
    h_layout2 := ui::HorizontalLayout(0, 0, w, 50, demo_scene)
    h_layout3 := ui::HorizontalLayout(0, 0, w, 50, demo_scene)

    v_layout.pack_start(h_layout1)
    v_layout.pack_start(h_layout2)
    v_layout.pack_start(h_layout3)

    h_layout1.pack_start(new ui::Text(0, 0, 200, 50, "Héllo world"))
    h_layout2.pack_center(new ui::Text(0, 0, 200, 50, "Hello world"))
    h_layout3.pack_end(new ui::Text(0, 0, 200, 50, "Hello world"))

    h_layout := ui::HorizontalLayout(0, 0, w, h, demo_scene)

    v_layout.pack_start(h_layout)
    // showing how an input box works
    h_layout.pack_center(new ui::TextInput(0, 50, 1000, 50))

    range := new ui::RangeInput(0, 150, 1000, 50)
    range->events.change += PLS_LAMBDA(float f):
      input::TouchEvent::MIN_PALM_SIZE = int(f * 1500 + 500);
      fb->waveform_mode = WAVEFORM_MODE_AUTO
    ;
    range->set_range(500, 2000)
    h_layout.pack_center(range)

    palm_area = new ui::Text(50, 150, 150, 50, "Palm Width:")
    palm_area->set_style(
      ui::Stylesheet()
        .valign(ui::Style::VALIGN::MIDDLE)
        .justify(ui::Style::JUSTIFY::LEFT))

    h_layout.pack_start(palm_area)


    pager := new ui::Pager(0, 0, 500, 500, NULL)
    pager->options = { "foo", "bar", "baz" }
    pager->setup_for_render()
    pager->events.selected += [=](string t):
      debug "PAGER SELECTED", t
      ui::MainLoop::hide_overlay()

    ;

    btn := new ui::Button(0, 250, 200, 50, "Show Pager")
    btn->mouse.click += [=](input::SynMotionEvent &ev):
      pager->show()
    ;

    h_layout.pack_center(btn)




    text_dropdown := new ui::TextDropdown(0, h-200, 200, 50, "Options")
    text_dropdown->dir = ui::TextDropdown::DIRECTION::UP
    ds := text_dropdown->add_section("options")
    ds->add_options({"foo", "bar", "baz"})

    text_dropdown->events.selected += PLS_LAMBDA(int idx):
      debug "SELECTED", idx, text_dropdown->options[idx]->name
    ;
    h_layout.pack_center(text_dropdown)

  def handle_key_event(input::SynKeyEvent &key_ev):
    debug "KEY PRESSED", key_ev.key

  def handle_motion_event(input::SynMotionEvent &syn_ev):
    touch := input::is_touch_event(syn_ev)
    static string last_text = ""
    if touch:
      is_palm := touch->is_palm()

      if touch->max_touch_area() == 0:
        palm_area->text = ""
      else if is_palm:
        palm_area->text = "Palm Down"
      else:
        palm_area->text = "Finger Down"

      if palm_area->text != last_text:
        palm_area->undraw()
        palm_area->dirty = 1
        fb := framebuffer::get()
        fb->waveform_mode = WAVEFORM_MODE_AUTO

      last_text = palm_area->text



  def run():

    ui::MainLoop::key_event += PLS_DELEGATE(self.handle_key_event)
    ui::MainLoop::motion_event += PLS_DELEGATE(self.handle_motion_event)
    ui::MainLoop::filter_palm_events = true

    // just to kick off the app, we do a full redraw
    ui::MainLoop::refresh()
    ui::MainLoop::redraw()

    while true:
      ui::MainLoop::main()
      ui::MainLoop::redraw()
      ui::MainLoop::read_input()


def main():
  App app
  app.run()
