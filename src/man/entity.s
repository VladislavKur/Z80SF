
.include "cpctelera.h.s"

;;
.area _DATA

;; Global Symbols
e_type_invalid::  .db 0x00
e_type_star::     .db 0x01
e_type_dead::     .db 0x80
e_type_default:  .db 0x7F
where_I_am:     .dw #0x0000 
auxDW:        .dw #0x0000

;; Entity Values
entity_type:      .db  #00      ;;Type of the Entity
entity_x::        .db  #79       ;; X(horizontal) value
entity_y::         .db  #80       ;; Y(vertical) Value
entity_vx::        .db  #1      ;; VX Speed value
entity_color::     .db  #0xFF       ;; COlor
entity_prevptr::   .db  #0xFF      ;; Last position of the Entity drawed

last_entity_pos_entities::  .dw  #0x0000

num_entities::    .db  #10
entities::       .ds  #60      ;;Array of 10 Entities (all 0 values) 6 spaces for entity || 1 for value



.globl man_init_entity
.globl man_create_entity
.globl man_destroy_entity

.globl sys_generator_newStar
.globl _main
;; 
.area _CODE


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                Start Entity
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
man_init_entity:
   ld    hl, #num_entities+0        ;; paso direccion de memoria a HL de numero de entidades
   ld    (hl),#0x00                 ;; pongo el valor de num entities a 0
   ld    hl, #entities
   ld    (last_entity_pos_entities),  hl;; guardo la posicion inicial de entities en last_pos
ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                CREATE NEW ENTITY
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
man_create_entity:
        ;; (hl) == 425f  hl =4254
        push de
        ld e, (hl)
        inc hl
        ld d, (hl)
        ex de, hl
        pop de

        
        ld a, (hl)
        cp  #0
        jr z,jumpy
    
        ld a, c                 ;;C values the TYpe Star
        cp #1
        jr  z, its_a_star           ;;if its a star dont change the C value
        ld a,(e_type_default)
        ld c, a                     ;; its not a star puts the 
        its_a_star:
       
        
      ld    hl, (last_entity_pos_entities)           ;; load to hl the next position of entities
      ld    a, (hl)
      cp    #0
      jr    nz, position_with_entity
      jumpy:
      ld    a, c            ;; 1st place get the type of the entity
      ld    (hl), a
      inc   hl                              ;; increase the memory ptr to 2nd place
      ld    a,(entity_x)                    
      ld    (hl),a                          ;; add the X position on 2nd place
      inc   hl
      ld    a, e                            ;; recieve the random number generated for 0-199 (negative)
      ld    (hl),a                          ;; and add it to the 3rd place for the height
      inc   hl
      ld    a, b                            ;; B is a random speed from -3,-1
      ld    (hl), a                         ;; added to the the 4th place
      inc   hl
      ld    a, (entity_color)               ;; color for the 5th place
      ld    (hl),a
      inc   hl
      ld    a, (entity_prevptr)             ;; last place he was to delete
      ld    (hl),a
      inc   hl
                 ;; last position have now the next entity position
      ld    hl,#num_entities                    
      inc   (hl)                             ;; increase the num_entities

    

    position_with_entity:
    ld    hl, (last_entity_pos_entities)
    .rept 6
        inc hl
    .endm
    ld    (last_entity_pos_entities), hl
ret
;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                Destroy Entity
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

man_destroy_entity:
ld  hl, #entities
    ld (where_I_am),hl
    ld a,l
    add #54
    ld l, a
    ex de, hl
        jumpdestroy:
        ld   bc, #0x0000
        ld   bc, (where_I_am)
        ld   ix, #0x000
        add  ix, bc 

        ld  a, (ix)
        cp #0x80
        jr nz, doitdestroy
            ld a, #0x00
            ld (ix), a
            ld hl, #num_entities
            dec (hl)
            
            jr finishdestroy
        doitdestroy:


        ld hl, #where_I_am
        .rept 6
            inc (hl)
        .endm


    ld bc, (where_I_am)
    ld  a, c
    cp  e               ;;#checking if "WIam" is the same,
                                    ;; that means i am in already updated
                                    ;; the last entity
    jr  nz, jumpdestroy                    ;; if i am not in the last entity, do next entity

    ld a, b
    cp d
    jr nz, jumpdestroy                     ;; checking if last entity and where i am in same place, finishes the update
                                    ;; Loop of all entities
    





    finishdestroy:

ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                Set 4 Destruction
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

man_set4Destruction_entity::
        ld  a, #0x00        
        ld  +4(ix),a        ;; color of the entity to white, will clear all the last positions of the entity
        ld  +1(ix),a
        
        ld  +3(ix),a
        
        ld a, (e_type_dead) 
        ld (ix), a      ;; change the type of the entity to errase the entity from the array
        
    

        ld b, #0xFF             ;; return FF for the to not move the X position of the entity
ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                free Space
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
man_free_entity::


    ld    a, (num_entities)             ;; meto en a lo que valga num entities para saber cuanto vale num entities
    cp    #10                           ;; compruebo si hay 10 entidades
    jr    z, entity_create_pausa        ;; si hay 10 entidades salgo del metodo

    call sys_generator_newStar           ;; there is enough space and create a new Star

    entity_create_pausa:     ;;leave the method
ret


man_search_for_space::
    ld  hl, #entities
    ld (where_I_am),hl
    ld a,l
    add #54
    ld l, a
    ex de, hl
        jumpsearch:
        ld   bc, #0x0000
        ld   bc, (where_I_am)
        ld   ix, #0x000
        add  ix, bc 

        ld  a, (ix)
        cp #0x00
        jr nz, doit
            ld  hl, #(where_I_am)
            push hl
               ld e, (hl)
               inc hl
               ld d, (hl)
               ex de, hl
            ld (last_entity_pos_entities), hl
            pop hl
            jr finish
        doit:


        ld hl, #where_I_am
        .rept 6
            inc (hl)
        .endm


    ld bc, (where_I_am)
    ld  a, c
    cp  e               ;;#checking if "WIam" is the same,
                                    ;; that means i am in already updated
                                    ;; the last entity
    jr  nz, jumpsearch                    ;; if i am not in the last entity, do next entity

    ld a, b
    cp d
    jr nz, jumpsearch                     ;; checking if last entity and where i am in same place, finishes the update
                                    ;; Loop of all entities
    





    finish:
ret