
.include "cpctelera.h.s"

.area _DATA
where_to_draw:  .dw #0xffff              ;; place where i will draw
where_I_am:     .dw #0x0000                ;; this one is for move for the entities array calculating
pos_x:          .db #0xFF
pos_y:          .db #0xFF
color:          .db #0xFF
prevptr:        .db #0xFF

finish_entities: .dw #0x0000
;; variables
.globl entity_x
.globl entity_y
.globl entity_prevptr
.globl entity_color
.globl last_entity_pos_entities
.globl entities
;; methods
.globl sys_render_update
.globl sys_render_init
;;video
.globl cpct_disableFirmware_asm
.globl cpct_getScreenPtr_asm
.globl cpct_setVideoMode_asm
.globl cpct_setPALColour_asm

.area _CODE

sys_render_1Entity::

    ld a, (ix)
    cp #0
    jr z, leave
    
    ld a, +5(ix)      
                                ;; ENTITY POSITION + 5
    cp #0xFF                      ;; Checking if preptr is 0 or not
    jr z, salta_render          ;; if prevptr is == 0

    ld de, #0xC000
    ld c, a
    ld a, +2(ix)
    ld b, a
    call cpct_getScreenPtr_asm 
    
    ld  (hl), #0x00

    salta_render:

    ;;(2B DE) screen_start	Pointer to the start of the screen (or a backbuffer)
    ;;(1B C ) x	[0-79] Bytes-aligned column starting from 0 (x coordinate,
    ;;(1B B ) y	[0-199] row starting from 0 (y coordinate) in bytes)
        ld de, #0xC000
        ld a,(pos_x)
        ld c, a
        ld a, (pos_y)
        ld b, a
        call cpct_getScreenPtr_asm          ;; in HL I have the position 
                                        ;;  of where i need to paint
        ld a, (color)
        ld  (hl), a
    
    leave:

ret



sys_render_update:
              ;;#memory adress of the entities array
    ld  hl, #entities
    ld (where_I_am),hl
    ld a,l
    add #54
    ld l, a
    ld (finish_entities), hl
   

    jump:

        ld   bc, #0x0000
        ld   bc, (where_I_am)
        ld   ix, #0x000
        add  ix, bc 

        

        ld  a, +1(ix)                   ;;a got the X of the entity
        ld  (pos_x), a
        ld  a, +2(ix)                   ;;a got the Y of the entity
        ld  (pos_y),a
        ld  a, +4(ix)                   ;;a got the Color of the entity
        ld  (color), a
        call sys_render_1Entity
        

                      ;; put the added speed to the X position
                        
        
   

        ld hl, #where_I_am
        .rept 6
            inc (hl)
        .endm

    ld hl,(finish_entities)
    ex de, hl
    ld bc, (where_I_am)
    ld  a, c
    cp  e               ;;#checking if "WIam" is the same,
                                    ;; that means i am in already updated
                                    ;; the last entity
    jr  nz, jump                    ;; if i am not in the last entity, do next entity

    ld a, b
    cp d
    jr nz, jump                     ;; checking if last entity and where i am in same place, finishes the update
                                    ;; Loop of all entities
    





    
    

ret



sys_render_init:
    ld hl, #entities
    ld (where_I_am), hl
    ld c, #0x00
    call	cpct_setVideoMode_asm ;; video mode 0

    ;; (1B L) pen	[0-16] Index of the palette colour to change.  Similar to PEN Number in BASIC.
    ;;(1B H) hw_ink	[0-31] New hardware colour value for the given palette index.
    ;;Assembly 
    ld	hl, #0x1410
    call cpct_setPALColour_asm              ;; Set border to HW_BLACK
ret

sys_borrar_star::




ret