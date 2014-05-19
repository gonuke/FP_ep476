module tree_functions_mod
  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  ! This is a module that contains subroutines for creating new nodes,
  ! extracting existing nodes from their current positions in the tree,
  ! and inserting nodes (new or previously existing) into the correct 
  ! position in the tree.  There are also subroutines for printing node
  ! relationships to the screen, and writing them to a .dot file to 
  ! produce a visual representation of the tree.          
  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  
  use tree_data_mod
  
  contains  
    subroutine create_node(id, new_node)
    !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    ! This subroutine allocates space for the new node being 
    ! inserted into the tree.  It also nullifies all of the 
    ! new node's associations
    !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    
      use tree_data_mod
    
      implicit none

      integer :: id   ! ID of the new node
      type(node), pointer, intent(inout)  :: new_node 
  
      allocate(new_node) 

      nullify(new_node%head)
      nullify(new_node%parent)
      nullify(new_node%fchild)
      nullify(new_node%lchild)
      nullify(new_node%rsib)
      nullify(new_node%lsib)
      nullify(new_node%cn)

      ! Set the new node's ID 
      new_node%id=id
  
      return  
    end subroutine create_node
    

    subroutine extract_node(cn)
    !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    ! This subroutine is called when a node already existing in the 
    ! tree, cn, needs to be removed from its current position.  It 
    ! will eventually be inserted back into the tree in a new position
    !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
   
      use tree_data_mod
    
      type(node), pointer, intent(inout) :: cn ! node to be extracted
      
      !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
      ! First, change cn's parent's relationships.
      ! If cn is the first child, it's next sibling becomes the new
      ! first child.  If cn is the last child, it's left sibling
      ! becomes the new last child. If cn is an only child, it's 
      ! It's parent now has no first or last child.
      !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
      if(cn%parent%fchild%id .eq. cn%id) then
          cn%parent%fchild=>cn%rsib
      end if
      if (cn%parent%lchild%id .eq. cn%id) then
          cn%parent%lchild => cn%lsib
      end if 

      !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
      ! Next, change cn's siblings' relationships.
      ! If cn has right and left siblings, those siblings will now 
      ! see each other as siblings and not cn. 
      !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
      if (associated(cn%rsib)) then
        cn%rsib%lsib => cn%lsib
      end if
      if (associated(cn%lsib)) then
        cn%lsib%rsib=>cn%rsib
      end if
    
      nullify(cn%rsib)
      nullify(cn%lsib)
      nullify(cn%parent)

    end subroutine extract_node


    subroutine insert_node(node_a, node_b)
    !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    ! This subroutine is called when node_a needs to be inserted as
    ! a child of node_b.
    !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
   
      use tree_data_mod
    
      type(node), pointer, intent(inout) :: node_b 
      type(node), pointer, intent(inout) :: node_a 
  
      !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
      ! Set a's parent as b. If b already has children, a will become
      ! b's last child. If b does not have children, a will become 
      ! b's first and last child.
      !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
      node_a%parent => node_b
      node_a%lsib=> node_b%lchild

      if (associated(node_b%lchild)) then
        node_b%lchild%rsib=>node_a
        nullify(node_a%rsib)
      else
        node_b%fchild=>node_a
      end if  

      node_b%lchild=>node_a
   
    end subroutine insert_node
    

    subroutine check_kids(node_p)
    !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    ! This subroutine can be used to quickly check if the first and 
    ! last child of some nodes are being set correctly.
    !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
      use tree_data_mod

      type(node), pointer, intent(inout) :: node_p
      type(node), pointer :: node_orig

      node_orig => node_p
      write(*,*) 'node orig, node p', node_orig%id, node_p%id    
      
      do while( associated(node_p%fchild))
!        write(*,*) 'node ', node_p%id, ' has 1st child ', node_p%fchild%id
 !       write(*,*) 'node ', node_p%id, ' has last child ', node_p%lchild%id
        node_p => node_p%fchild
      enddo

      node_p => node_orig

      write(*,*) '2. node orig, node p', node_orig%id, node_p%id    
    end subroutine check_kids
    

    subroutine write_tree(node_h,step)
    !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    ! This subroutine writes the node-parent relationships to the 
    ! screen and also writes a file (tree.dot) that can be converted 
    ! to a .png file in order to visualize the tree. The node2dot 
    ! subroutine is called to print the correct arrows between nodes.
    !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!    

      type(node), pointer, intent(inout) :: node_h
      type(node), pointer                :: cn
      integer :: i
      integer, intent(in) :: step
      character(12) :: filename
      
      ! Header of the .dot file
      write(filename,'(A5,i1,a4)') 'tree_',step,'.dot'
      open(unit=10, file=filename, status='replace')
      write(10, fmt=*)'digraph geometry {' 
      write(10, fmt=*)'size="6,4"; ratio = fill;'
      write(10, fmt=*)'node[style=filled];'
     
      ! Header for screen output of parent relationships
      write(*,*) 'These are the nodes and their parents'
      write(*,*) '    Node ID   ','    ->  ', '  Parent ID'
 
      cn => node_h
      
      !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
      ! This loop will traverse the tree until all node 
      ! relationships have been written
      !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
      do while (associated(cn))
        
        CALL node2dot(cn) 

        ! Print parent relationships to screen
        write(*,*) cn%id,'      ->', cn%parent%id
        
        if (associated(cn%fchild)) then
          cn=>cn%fchild
        else
          if (associated (cn%rsib)) then
            cn=>cn%rsib
          else
            do while (associated(cn%parent) .and. &
                      .not.  associated(cn%parent%rsib))
              cn=>cn%parent
            end do
            if (associated(cn%parent)) then
              cn=>cn%parent%rsib
            else
              nullify(cn)
            end if
          end if
        end if
      end do

      write(10, fmt=*) '}'
      
      close(10)
    
    end subroutine write_tree


    subroutine node2dot(node_p)
    !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    ! This subroutine prints the properly formatted
    ! node relationships for the .dot file.  
    ! Parent: red arrow
    ! First child: dark blue; Last child: light blue
    ! Right sibling: dark purple; Left sibling: light purple
    !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
     
      type(node), pointer, intent(inout) :: node_p !relationships will
                                                   !be printed for node_p

      if (associated(node_p%parent)) then
        write(10, fmt=*) node_p%id,'->',node_p%parent%id, &
                        '[color="crimson"];'
      end if
     
      if (associated(node_p%fchild)) then
        write(10, fmt=*) node_p%id,'->',node_p%fchild%id, &
                       '[color="blue4"];'
        write(10, fmt=*) node_p%id,'->',node_p%lchild%id, &
                       '[color="deepskyblue"];'
        write(10, fmt=*) '{rank=same;', node_p%fchild%id, &
                                     node_p%lchild%id, '}'
      end if
     
    
      if (associated(node_p%rsib)) then
        write(10, fmt=*) node_p%id,'->',node_p%rsib%id, &
                        '[color="darkorchid4"];'
        write(10, fmt=*) '{rank=same;', node_p%id, &
                                      node_p%rsib%id, '}'
      end if
     
      if (associated(node_p%lsib)) then
        write(10, fmt=*) node_p%id,'->',node_p%lsib%id, &
                        '[color="darkorchid1"];'
      end if
     
    end subroutine node2dot

end module tree_functions_mod

module tree_insertion_mod
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! This module contains a routine for finding a node's correct 
! position in the tree.  
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
contains
    subroutine insert_in_tree(part, head, step)
      use tree_data_mod
      use tree_functions_mod
      use volume_functions_mod
    
      implicit none
    
      type(node), pointer, intent(inout) :: head ! top of the tree
      type(node), pointer, intent(inout) :: part ! incoming node
      type(node), pointer :: cn        ! current node in tree to test
      type(node), pointer :: next_cn   ! place holder for next cn
      type(node), pointer :: cn_parent ! place holder for cn's parent
      integer, intent(in) :: step
    
      logical :: insertion ! True if new part inserted into tree 
      logical :: inside    ! T/F result from A in B query
    
      ! The first test node is the top of the tree
      cn => head
       
      ! Initialize insertion to be false 
      insertion = .false.
    
      !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
      ! This loop contains the logic to find a new node's relationship
      ! to existing nodes in the tree and then insert it based upon 
      ! those relationships. Every new node will start with a test at 
      ! the head of the tree and then work it's way down and across 
      ! the existing nodes, testing it's inside/outside/beside 
      ! relationships until it finds its place.
      !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
      do while (insertion .eqv. .false.)
         if ( is_A_in_B(part, cn) .eqv. .true. ) then
           if (associated(cn%fchild)) then
              cn=>cn%fchild
              insertion=.false.
           else
              CALL insert_node(part, cn)
             insertion=.true.
           endif
         
         else
           next_cn=>cn%rsib
           cn_parent=>cn%parent
  
           if  ( is_A_in_B(cn, part) .eqv. .true. ) then
             write(*,*) 'cn is ', cn%id
             CALL extract_node(cn)
             CALL insert_node(cn,part)
           end if
         
           if (associated(next_cn)) then
             cn=>next_cn
             insertion=.false.
           else
             CALL insert_node(part,cn_parent)
             insertion=.true.
           end if
 
         endif

      call check_kids(head)
       
      end do
    
      call write_tree(head,step)

    end subroutine insert_in_tree

end module tree_insertion_mod

program tree_driver
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! This is program will build a hierarchical tree!
! based on toplogical information & arrangement !
! of 3D entities                                !
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! Author: C.A.D'Angelo                          !
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! Date: 05/15/2014                              !
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

use tree_insertion_mod
use tree_data_mod
use tree_functions_mod
use volume_data_mod

implicit none

type(node), pointer :: head     ! head of the tree
type(node), target  :: new_node ! next node to be inserted 
type(node), pointer :: tmp_node ! temporary node

integer :: vols, dagmc_num_vol ! number of volumes in geometry 
integer :: dagmc_vol_id        ! volume ID number from output dagmc function
integer :: i, vol_id           
integer :: ios                 ! input/output status
integer, allocatable :: vol_parse_order(:) ! array of length, vols, used to 
                                         ! change order volumes are parsed

real :: rand_num

character(len=80) :: filename   ! name of geometry file
character(20) :: rand_arg
integer :: rand_seed

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! Setup DAGMC problem (use idagmc.cpp)
! dagmcinit reads in and initialize the .h5m file
! dagmc_num_vol finds the total number of volumes in the geometry
filename="nested_vol.h5m"
CALL dagmcinit(filename//char(0),len_trim(filename)) 

vols=dagmc_num_vol()
write (*,*) 'The number of volumes is', vols

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! In order to check if volume A is inside, outside, or
! beside another volume B, we need a point on the surface of A.
! Assuming the surfaces DO NOT overlap, if A is inside B, 
! every point on A's surface will be inside B.
!
! Open the file containing the surface points and allocate an array
! that contains the x,y,z coordinates of the surface points.
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
open (unit=20,file='vol_surf_points.txt', status='old', &
      err=20, iostat=ios)

allocate (volume_surfpoints(vols,3))

do i=1, vols-1
  read(20,*) volume_surfpoints(i,1), volume_surfpoints(i,2), &
             volume_surfpoints(i,3)
end do

close (20)

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! Create the head node;
! It is an imaginary node at the top of the tree with ID=-1
! All other nodes are inside it
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

CALL create_node(-1, head)

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! The order of entries in  vol_parse_order array can be changed to 
! test that the same tree is built no matter which order the volumes
! are seen. (This is only for this particular 6 volume geometry)
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

CALL getarg(1,rand_arg)
read(rand_arg,*) rand_seed

do i = 1, rand_seed
   call random_number(rand_num)
end do

allocate( vol_parse_order(1:(vols-1)) )

do i = 1, vols-1
   call random_number(rand_num)
   vol_id = rand_num*i + 1
   vol_parse_order(i) = vol_parse_order(vol_id)
   vol_parse_order(vol_id) = i
end do

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! This loop will get the correct volume ID number from the 
! dagmc_vol_id function contained in idagmc.cpp. It then calls create 
! node to allocate space and nullify it's attributes before 
! insert_in_tree is called which contains the logic to find the new 
! node's correct position in the tree.
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
do i=1, vols-1

 allocate(tmp_node)

 vol_id = dagmc_vol_id(vol_parse_order(i))
 write(*,*) 'Volume ', i, ' has ID ', vol_id

 CALL create_node(vol_id,tmp_node)
 CALL insert_in_tree(tmp_node, head,i)

end do

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! Finally, we want to see if the tree we built is correct.  Call the
! write_tree subroutine to print the node-parent relationships to the
! screen and also write a .dot file that can be converted to a .png
! file for visualization with:
! >> dot -Tpng tree.dot -o tree.png
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

CALL write_tree(head,0)

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! If the file with surface points could not be found or opened, 
! an error message will be printed to screen.
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
stop

20 write(*,*) 'Could not open vol_surf_points.txt'

end program tree_driver







