
.include "cpctelera.h.s"

.area _DATA


.globl cpct_disableFirmware_asm
.globl cpct_getScreenPtr_asm

;;man
.globl man_init_entity
.globl man_free_entity

.globl man_destroy_entity
;;sys
.globl sys_render_init
.globl sys_physics_update
.globl sys_render_update
.globl cpct_waitVSYNC_asm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.area _CODE


_main::

    call cpct_disableFirmware_asm

 
   call man_init_entity
   call sys_render_init
   


   sigueaquipapa:
      
      call man_free_entity
      call sys_physics_update
      call sys_render_update
      call man_destroy_entity
      halt
      halt
      call cpct_waitVSYNC_asm
      

   jr  sigueaquipapa

