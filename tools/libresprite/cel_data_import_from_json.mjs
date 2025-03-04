// This script EXTRACTS the cel data from a Libresprite JSON sheet
// and puts it INTO the currently open Libresprite file.
//
// Importantly, it only does so for the layer called "data". That means
// you can write tools/etc that modify the cel data on the JSON sheet and
// then easily get the data back into the Libresprite sheet. All this to make
// a workflow for getting hitboxes and hurtboxes on your aseprite
// animations.
