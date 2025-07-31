function []= projectgroup6()
clear
clc
format bank
%p= Total plan dimension, inside edge to inside edge
%r1=1st Room dimension
%r2= 2nd Room Dimension
%v= Verandah Dimension (Outer Edge to Outer Edge)
%tw= wall thickness
%hs= height of section (from floor to ceiling)
%cd= dimension of column
%cn= no. of column
%d1= Door dimension in [x z] direction
%n1= Number of door
%w1= Window Dimension in [x z] direction
%n2= Number of Window
%sn= Number of stairs
%sl= Length of stairs
%CorD= Dimension of cornice in [x y] direction
%CorT= Thickness of Cornice
%TiP= Thickness of inside plastering
%ToP= Thickness of Outside Plastering
%PwP= Parapet Wall Plastering
disp ("All dimesion Must be written in Excel according to instruction");
x= xlsread("projectgroup6.xlsx");
p= x(1,:); %% Dimension of the Plan (inner edge to inner edge);
r1= x(2,:); %% Dimension of Room-01;
r2= x(3,:); %% Dimension of Room-02;
v= x(4,:); %% Dimension of Veranda (Outer Edge to Outer Edge);
tw=10/12;
hs=x(5,1); %% Height of Section;
cd=x(6,:); %% Dimension of Column? (in [x y] direction);
cn= x(7,1); %% Number of Column in Verandah;

if ((r1(1)+r2(1)+tw==p(1))&&(r1(2)+v(2)+tw==p(2))&&(r1(1)+r2(1)+3*tw==v(1)&&r1(2)==r2(2))) %%case-01

    %BFS
    BFS=r1(1)*r1(2)+r2(1)*r2(2)+(v(1)-2*tw)*(v(2)-tw);

    %CC
    CC=(r1(1)*r1(2)+r2(1)*r2(2)+(v(1)-2*tw)*(v(2)-tw))*(3/12);

    d1=x(8,:); %% Dimension of door in [x z] direcction;
    n1=x(9,1); %% Number of door;
    w1=x(10,:); %% Dimension of window? [x z];
    n2=x(11,1); %% Number of window;
    sn=x(12,1); %% No of Stairs;
    sl=x(13,1); %%Length of Stairs;
    if (d1(1)*n1+w1(1)*n2)<=((r1(1)+r2(1)+3*tw)*2+(r1(2)*3))
        %Floor Finish
        FloorFinish= (r1(1)*r1(2)+r2(1)*r2(2)+v(1)*v(2)-cn*cd(1)*cd(2)+tw*d1(1)*n1+(tw+0.5)*sl* sn)*(1/(4*12));
        
        %Brickwork
        Brickwork=((r1(1)+r2(1)+3*tw)*2+(r1(2)*3))*tw*hs-d1(1)*d1(2)*tw*n1-w1(1)*w1(2)*tw*n2-((r1(1)+r2(1)+3*tw)*2+(r1(2)*3))*tw*(6/12);
        
        %RCC in column
        RCCInColumn=cd(1)*cd(2)*hs*cn;
        
        %RCC in Lintel
        RCCInLintel=((r1(1)+r2(1)+3*tw)*2+(r1(2)*3))*tw*(6/12);
        %%continuous Lintel all over the perimeter
       
    else error('Length of doors and windows must be less than perimeter')
    end
    
    %RCC in Roof
    CorD= x(14,:); %% Dimension of cornice in [x y] direction;
    CorT= x(15,1); %%input ("Thickness of Cornice?     ");
    RCCinRoof= CorD(1)*CorD(2)*CorT;
    
    %Lime Concrete in Roof
    %Bricks in Parapet
    PwHT=x(16,:); %% Height and Thickness of Parapet Wall (in [h t] format)
    O= input("Is the parapet Wall above Cornice? (Y/N)    ");
    if O=="Y"
        LimeConcreteInRoof=(CorD(1)-2*PwHT(2))*(CorD(2)-2*PwHT(2))*(3/12);
        BricksInParapet= (CorD(1)*2+((CorD(2)-PwHT(2)*2)*2))*PwHT(1)*PwHT(2);
    else
        LimeConcreteInRoof=p(1)*(p(2)-PwHT(2))*(3/12);
        BricksInParapet= 2*((p(1)+2*PwHT(2))+p(2)-tw)*PwHT(1)*PwHT(2);
    end
    
    %Brickwork in Stair
    BrS=0;
    for i=1:1:sn
        BrSu= (10/12) *(6/12)* sl*i;
        BrS= BrS+ BrSu;
    end
    BrickworkInStairs=BrS;
    
    CdN= x(17,1); %% No of Common Door
    DL= x(18,:); %% Total Dropwall Length in [x y] direction
    Dht=x(19,:); %% Height and Thickness of Dropwall? (in [h t] format)
   
    %Inside Plastering
    %sh=skirting height
    sh=10/12;
    TiP= 0.25/12; 

    rm1=2*(r1(1)+r1(2))*(hs-sh)*TiP; %for room 1
    rm2=2*(r2(1)+r2(2))*(hs-sh)*TiP; %for room 2
    vp= v(1)*(hs-sh)*TiP; %for verandah
    cp=((r1(1)*r1(2)+r2(1)*r2(2))+v(1)*v(2))*TiP; %Ceiling
    dp=(DL(1)+ 2* DL(2))*Dht(1)*TiP; %dropwall
    edge=n1*(2*(d1(2)-sh)+d1(1))*tw*TiP + n2*(2*(w1(1)+w1(2))*tw*TiP); %edge of door and window;
    %deduct
    CwN= x(20,1); %% No of Common Window between rooms and verandah;
    deduct= CwN*2*w1(1)*w1(2)*TiP+(n2-CwN)*w1(1)*w1(2)*TiP+CdN*2*d1(1)*(d1(2)-sh)*TiP+(n1-CdN)*d1(1)*(d1(2)-sh)+2*Dht(1)*Dht(2)*TiP+cn*cd(1)*cd(2)*TiP+ (DL(1)+2*DL(2))*Dht(2)*TiP;
    InsidePlastering = rm1+ rm2+ vp+ cp+ dp+ edge- deduct;
    
    %Outside Plastering
    Own= x(21,1); %% Number of Outside Window
    ToP= 0.5/12;
    OutsideWallP=(p(1)+2*tw+2*(r1(2)+2*tw))*hs*ToP-(Own*(w1(1)*w1(2)))*ToP;
    ColP= cn*2*(cd(1)+cd(2))*(hs-sh)*ToP-2*cn*Dht(1)*Dht(2)*ToP;
    DropWallP=  (DL(1)+2*DL(2))*(Dht(2)+Dht(1))*ToP;
    StP=0;
    for(i=1:1:sn)
        StPu= 2* (10/12) *(6/12)* ToP*i;
        StP= StP+ StPu;
    end
    StP;
    if O=="Y"
        PwP= 2*(CorD(1)+CorD(2))*PwHT(1)*ToP+2*(CorD(1)+CorD(2)-2*PwHT(2))*PwHT(2)*ToP+2*(CorD(1)-2*PwHT(2)+CorD(2)-2*PwHT(2))*PwHT(1)*ToP;
        CoP=2*(CorD(1)+CorD(2))*CorT*ToP+(CorD(1)-(p(1)+2*tw))*(p(2)+tw)*ToP;
    else
        PwP= 2*(p(1)+2*tw+p(2)+tw)*PwHT(1)*ToP+2*(p(1)+2*tw+p(2)-tw)*PwHT(2)*ToP+2*(p(1)+2*tw-2*PwHT(2)+p(2)+tw-2*PwHT(2))*PwHT(1)*ToP;
        CoP=2*(CorD(1)+CorD(2))*CorT*ToP+2*(CorD(1)-(p(1)+2*tw))*(p(2)+tw)*ToP;
    end
    PwP;
    CoP;
    OutsidePlastering= OutsideWallP+ColP+ DropWallP+ StP+PwP+CoP;
    
    %Skirting
    Skirting= (2*((r1(1)+r1(2))+r2(1)+r2(2)+(cd(1)+cd(2))*cn-d1(1)*CdN)+v(1)-(n1-CdN)*d1(1))*(10/12)*(0.75/12);

    %RCC in Dropwall
    RCCinDropwall= (DL(1)+DL(2)*2)*Dht(1)*Dht(2);

   quantity=[BFS CC FloorFinish Brickwork RCCInColumn RCCInLintel RCCinRoof LimeConcreteInRoof BricksInParapet BrickworkInStairs InsidePlastering OutsidePlastering Skirting RCCinDropwall]';
   rate=x(1:14,5);
   TC=[quantity.*rate];
   INo=[1:14]';
     A = table([INo], [quantity],[rate],[TC],...
    'VariableNames',{'Item No' 'Quantity' 'Per Unit Cost(BDT)' 'Cost of Individual Item(BDT)'},...
    'RowNames',{'BFS' 'CC' 'FloorFinish' 'Brickwork' 'RCCInColumn' 'RCCInLintel' 'RCCinRoof' 'LimeConcreteInRoof' 'BricksInParapet' 'BrickworkInStairs' 'InsidePlastering' 'OutsidePlastering' 'Skirting' 'RCCinDropwall'})

     x = sum(TC, 'all');
     format short
     y= round(x);
     TotalCost = fprintf('<strong>Estimated Total Cost is %d Tk</strong>\n', y);
     disp("Thanks for staying with us")

elseif ((r2(1)==p(1))&&(r1(2)+r2(2)+tw==p(2))&&(r1(1)+v(1)==r2(1))&&(r1(2)==v(2)-tw)) %%case-02

    %BFS
    BFS=r1(1)*r1(2)+r2(1)*r2(2)+(v(1)-tw)*(v(2)-tw);

    %CC
    CC=(r1(1)*r1(2)+r2(1)*r2(2)+(v(1)-tw)*(v(2)-tw))*(3/12);

    d1=x(8,:); %% Dimension of door in [x z] direcction;
    n1=x(9,1); %% Number of door;
    w1=x(10,:); %% Dimension of window? [x z];
    n2=x(11,1); %% Number of window;
    sn=x(12,1); %% No of Stairs;
    sl=x(13,1); %%Length of Stairs;
    if (d1(1)*n1+w1(1)*n2)<=((r1(1)+2*r1(2)+2*tw)+2*(r2(1)+2*tw+r2(2)))
        %Floor Finish
        FloorFinish= (r1(1)*r1(2)+r2(1)*r2(2)+v(1)*v(2)-cn*cd(1)*cd(2)+tw*d1(1)*n1+(tw+0.5)*sl* sn)*(1/(4*12)) ;
        
        %Brickwork
        Brickwork=((r1(1)+2*r1(2)+2*tw)+2*(r2(1)+2*tw+r2(2)))*tw*hs-d1(1)*d1(2)*tw*n1-w1(1)*w1(2)*tw*n2-((r1(1)+2*r1(2)+2*tw)+2*(r2(1)+2*tw+r2(2)))*tw*(6/12);
        
        %RCC in column
        RCCInColumn=cd(1)*cd(2)*hs*cn;
        
        %RCC in Lintel
        RCCInLintel=((r1(1)+2*r1(2)+2*tw)+2*(r2(1)+2*tw+r2(2)))*tw*(6/12);
        %%continuous Lintel all over the perimeter
       
    else error('Length of doors and windows must be less than perimeter')
    end
    
    %RCC in Roof
    CorD= x(14,:); %% Dimension of cornice in [x y] direction;
    CorT= x(15,1); %%input ("Thickness of Cornice?     ");
    RCCinRoof= CorD(1)*CorD(2)*CorT;
    
    %Lime Concrete in Roof
    %Bricks in Parapet
    PwHT=x(16,:); %% Height and Thickness of Parapet Wall (in [h t] format)
    O= input("Is the parapet Wall above Cornice? (Y/N)");
    if O=="Y"
        LimeConcreteInRoof=(CorD(1)-2*PwHT(2))*(CorD(2)-2*PwHT(2))*(3/12);
        BricksInParapet= (CorD(1)*2+((CorD(2)-PwHT(2)*2)*2))*PwHT(1)*PwHT(2);
    else
        LimeConcreteInRoof=p(1)*(p(2)-PwHT(2))*(3/12);
        BricksInParapet= 2*((p(1)+2*PwHT(2))+p(2)-tw)*PwHT(1)*PwHT(2);
    end
    
    %Brickwork in Stair
    BrS=0;
    for(i=1:1:sn)
        BrSu= (10/12) *(6/12)* sl*i;
        BrS= BrS+ BrSu;
    end
    BrickworkInStairs=BrS;
    
    
    CdN= x(17,1); %% No of Common Door
    DL= x(18,:); %% Total Dropwall Length in [x y] direction
    Dht=x(19,:); %% Height and Thickness of Dropwall? (in [h t] format)

    %Inside Plastering
    %sh=skirting height
    sh=10/12;
    TiP= 0.25/12; 

    rm1=2*(r1(1)+r1(2))*(hs-sh)*TiP; %for room 1
    rm2=2*(r2(1)+r2(2))*(hs-sh)*TiP; %for room 2
    vp= (v(1)+v(2))*(hs-sh)*TiP; %for verandah
    cp=((r1(1)*r1(2)+r2(1)*r2(2))+v(1)*v(2))*TiP; %Ceiling
    dp=(DL(1)+DL(2))*Dht(1)*TiP; %dropwall
    edge=n1*(2*(d1(2)-sh)+d1(1))*sh*TiP + n2*(2*(w1(1)+w1(2))*sh*TiP); %edge of door and window;
    %deduct
    CwN= x(20,1); %% No of Common Window between rooms and verandah
    deduct= CwN*2*w1(1)*w1(2)*TiP+(n2-CwN)*w1(1)*w1(2)*TiP+CdN*2*d1(1)*(d1(2)-sh)*TiP+(n1-CdN)*d1(1)*(d1(2)-sh)+2*Dht(1)*Dht(2)*TiP+cn*cd(1)*cd(2)*TiP+ (DL(1)+DL(2))*Dht(2)*TiP;
    InsidePlastering = rm1+ rm2+ vp+ cp+ dp+ edge- deduct;
    
    %Outside Plastering
    Own= x(21,1); %% Number of Outside Window;  
    ToP= 0.5/12;
    OutsideWallP=(r1(1)+2*tw+p(2)+tw+r2(1)+2*tw+r2(2)+2*tw)*hs*ToP-(Own*(w1(1)*w1(2)))*ToP;
    ColP= cn*2*(cd(1)+cd(2))*(hs-sh)*ToP-2*cn*Dht(1)*Dht(2)*ToP;
    DropWallP=  (DL(1)+DL(2))*(Dht(2)+Dht(1))*ToP;
    StP=0;
    for(i=1:1:sn)
        StPu= 2* (10/12) *(6/12)* ToP*i;
        StP= StP+ StPu;
    end
    StP;
    if O=="Y"
        PwP= 2*(CorD(1)+CorD(2))*PwHT(1)*ToP+2*(CorD(1)+CorD(2)-2*PwHT(2))*PwHT(2)*ToP+2*(CorD(1)-2*PwHT(2)+CorD(2)-2*PwHT(2))*PwHT(1)*ToP;
        CoP=2*(CorD(1)+CorD(2))*CorT*ToP+(CorD(1)-(p(1)+2*tw))*(p(2)+tw)*ToP;
    else
        PwP= 2*(p(1)+2*tw+p(2)+tw)*PwHT(1)*ToP+2*(p(1)+2*tw+p(2)-tw)*PwHT(2)*ToP+2*(p(1)+2*tw-2*PwHT(2)+P(2)+tw-2*PwHT(2))*PwHT(1)*ToP;
        CoP=2*(CorD(1)+CorD(2))*CorT*ToP+2*(CorD(1)-(p(1)+2*tw))*(p(2)+tw)*ToP;
    end
    PwP;
    OutsidePlastering= OutsideWallP+ColP+ DropWallP+ StP+PwP+CoP;
    
    %Skirting
    Skirting= (2*((r1(1)+r1(2))+r2(1)+r2(2)+(cd(1)+cd(2))*cn-d1(1)*CdN)+(v(1)+v(2))-(n1-CdN)*d1(1))*(sh)*(0.75/12);

    %RCC in Dropwall
    RCCinDropwall= (DL(1)+DL(2))*Dht(1)*Dht(2);

     quantity=[BFS CC FloorFinish Brickwork RCCInColumn RCCInLintel RCCinRoof LimeConcreteInRoof BricksInParapet BrickworkInStairs InsidePlastering OutsidePlastering Skirting RCCinDropwall]';
     rate=x(1:14,5);
     TC=[quantity.*rate];
     INo=[1:14]';
     A = table([INo], [quantity],[rate],[TC],...
    'VariableNames',{'Item No' 'Quantity' 'Per Unit Cost(BDT)' 'Cost of Individual Item(BDT)'},...
    'RowNames',{'BFS' 'CC' 'FloorFinish' 'Brickwork' 'RCCInColumn' 'RCCInLintel' 'RCCinRoof' 'LimeConcreteInRoof' 'BricksInParapet' 'BrickworkInStairs' 'InsidePlastering' 'OutsidePlastering' 'Skirting' 'RCCinDropwall'})
     x = sum(TC, 'all');
     format short
     y= round(x);
     TotalCost = fprintf('<strong>Estimated Total Cost is %d Tk</strong>\n', y);
     disp("Thanks for staying with us")
     
elseif ((r1(2)==p(2))&&(r1(1)+2*tw+r2(1)==p(1))&&(r2(2)+v(2)==r1(2))) %%case-03
    temp= p(2); p(2)=p(1); p(1)=temp; %%swap the x and y dimension of plan
    temp= r1(2); r1(2)=r1(1); r1(1)=temp; %%swap the x and y dimension of room-01
    temp= r2(2); r2(2)=r2(1); r2(1)=temp; %%swap the x and y dimension of room-02
    temp= v(2); v(2)=v(1); v(1)=temp; %%swap the x and y dimension of verandah
    temp=r1; r1=r2; r2=temp; %%Replace the values of room-01 and room-02

    %Now its a condition of case 02

    %BFS
    BFS=r1(1)*r1(2)+r2(1)*r2(2)+(v(1)-tw)*(v(2)-tw);

    %CC
    CC=(r1(1)*r1(2)+r2(1)*r2(2)+(v(1)-tw)*(v(2)-tw))*(3/12);

    d1=x(8,:); %% Dimension of door in [x z] direcction;
    n1=x(9,1); %% Number of door;
    w1=x(10,:); %% Dimension of window? [x z];
    n2=x(11,1); %% Number of window;
    sn=x(12,1); %% No of Stairs;
    sl=x(13,1); %%Length of Stairs;
    if (d1(1)*n1+w1(1)*n2)<=((r1(1)+2*r1(2)+2*tw)+2*(r2(1)+2*tw+r2(2)))
        %Floor Finish
        FloorFinish= (r1(1)*r1(2)+r2(1)*r2(2)+v(1)*v(2)-cn*cd(1)*cd(2)+tw*d1(1)*n1+(tw+0.5)*sl* sn)*(1/(4*12)) ;
        
        %Brickwork
        Brickwork=((r1(1)+2*r1(2)+2*tw)+2*(r2(1)+2*tw+r2(2)))*tw*hs-d1(1)*d1(2)*tw*n1-w1(1)*w1(2)*tw*n2-((r1(1)+2*r1(2)+2*tw)+2*(r2(1)+2*tw+r2(2)))*tw*(6/12);
        
        %RCC in column
        RCCInColumn=cd(1)*cd(2)*hs*cn;
        
        %RCC in Lintel
        RCCInLintel=((r1(1)+2*r1(2)+2*tw)+2*(r2(1)+2*tw+r2(2)))*tw*(6/12);
        %%continuous Lintel all over the perimeter
       
    else error('Length of doors and windows must be less than perimeter')
    end
    
    %RCC in Roof
    CorD= x(14,:); %% Dimension of cornice in [x y] direction;
    CorT= x(15,1); %%input ("Thickness of Cornice?     ");
    RCCinRoof= CorD(1)*CorD(2)*CorT;
    
    %Lime Concrete in Roof
    %Bricks in Parapet
    PwHT=x(16,:); %% Height and Thickness of Parapet Wall (in [h t] format)
    O= input("Is the parapet Wall above Cornice? (Y/N)");
    if O=="Y"
        LimeConcreteInRoof=(CorD(1)-2*PwHT(2))*(CorD(2)-2*PwHT(2))*(3/12);
        BricksInParapet= (CorD(1)*2+((CorD(2)-PwHT(2)*2)*2))*PwHT(1)*PwHT(2);
    else
        LimeConcreteInRoof=p(1)*(p(2)-PwHT(2))*(3/12);
        BricksInParapet= 2*((p(1)+2*PwHT(2))+p(2)-tw)*PwHT(1)*PwHT(2);
    end
    
    %Brickwork in Stair
    BrS=0;
    for(i=1:1:sn)
        BrSu= (10/12) *(6/12)* sl*i;
        BrS= BrS+ BrSu;
    end
    BrickworkInStairs=BrS;
    
    
    CdN= x(17,1); %% No of Common Door
    DL= x(18,:); %% Total Dropwall Length in [x y] direction
    Dht=x(19,:); %% Height and Thickness of Dropwall? (in [h t] format)

    %Inside Plastering
    %sh=skirting height
    sh=10/12;
    TiP= 0.25/12; 

    rm1=2*(r1(1)+r1(2))*(hs-sh)*TiP; %for room 1
    rm2=2*(r2(1)+r2(2))*(hs-10/12)*TiP; %for room 2
    vp= (v(1)+v(2))*(hs-sh)*TiP; %for verandah
    cp=((r1(1)*r1(2)+r2(1)*r2(2))+v(1)*v(2))*TiP; %Ceiling
    dp=(DL(1)+DL(2))*Dht(1)*TiP; %dropwall
    edge=n1*(2*(d1(2)-sh)+d1(1))*sh*TiP + n2*(2*(w1(1)+w1(2))*sh*TiP); %edge of door and window;
    %deduct
    CwN= x(20,1); %% No of Common Window between rooms and verandah
    deduct= CwN*2*w1(1)*w1(2)*TiP+(n2-CwN)*w1(1)*w1(2)*TiP+CdN*2*d1(1)*(d1(2)-sh)*TiP+(n1-CdN)*d1(1)*(d1(2)-sh)+2*Dht(1)*Dht(2)*TiP+cn*cd(1)*cd(2)*TiP+ (DL(1)+DL(2))*Dht(2)*TiP;
    InsidePlastering = rm1+ rm2+ vp+ cp+ dp+ edge- deduct;
    
    %Outside Plastering
    Own= x(21,1); %% Number of Outside Window;  
    ToP= 0.5/12;
    OutsideWallP=(r1(1)+2*tw+p(2)+tw+r2(1)+2*tw+r2(2)+2*tw)*hs*ToP-(Own*(w1(1)*w1(2)))*ToP;
    ColP= cn*2*(cd(1)+cd(2))*(hs-sh)*ToP-2*cn*Dht(1)*Dht(2)*ToP;
    DropWallP=  (DL(1)+DL(2))*(Dht(2)+Dht(1))*ToP;
    StP=0;
    for(i=1:1:sn)
        StPu= 2* (10/12) *(6/12)* ToP*i;
        StP= StP+ StPu;
    end
    StP;
    if O=="Y"
        PwP= 2*(CorD(1)+CorD(2))*PwHT(1)*ToP+2*(CorD(1)+CorD(2)-2*PwHT(2))*PwHT(2)*ToP+2*(CorD(1)-2*PwHT(2)+CorD(2)-2*PwHT(2))*PwHT(1)*ToP;
        CoP=2*(CorD(1)+CorD(2))*CorT*ToP+(CorD(1)-(p(1)+2*tw))*(p(2)+tw)*ToP;
    else
        PwP= 2*(p(1)+2*tw+p(2)+tw)*PwHT(1)*ToP+2*(p(1)+2*tw+p(2)-tw)*PwHT(2)*ToP+2*(p(1)+2*tw-2*PwHT(2)+P(2)+tw-2*PwHT(2))*PwHT(1)*ToP;
        CoP=2*(CorD(1)+CorD(2))*CorT*ToP+2*(CorD(1)-(p(1)+2*tw))*(p(2)+tw)*ToP;
    end
    PwP;
    OutsidePlastering= OutsideWallP+ColP+ DropWallP+ StP+PwP+CoP;
    
    %Skirting
    Skirting= (2*((r1(1)+r1(2))+r2(1)+r2(2)+(cd(1)+cd(2))*cn-d1(1)*CdN)+(v(1)+v(2))-(n1-CdN)*d1(1))*(sh)*(0.75/12);

    %RCC in Dropwall
    RCCinDropwall= (DL(1)+DL(2))*Dht(1)*Dht(2);

     quantity=[BFS CC FloorFinish Brickwork RCCInColumn RCCInLintel RCCinRoof LimeConcreteInRoof BricksInParapet BrickworkInStairs InsidePlastering OutsidePlastering Skirting RCCinDropwall]';
     rate=x(1:14,5);
     TC=[quantity.*rate];
     INo=[1:14]';
     A = table([INo], [quantity],[rate],[TC],...
    'VariableNames',{'Item No' 'Quantity' 'Per Unit Cost(BDT)' 'Cost of Individual Item(BDT)'},...
    'RowNames',{'BFS' 'CC' 'FloorFinish' 'Brickwork' 'RCCInColumn' 'RCCInLintel' 'RCCinRoof' 'LimeConcreteInRoof' 'BricksInParapet' 'BrickworkInStairs' 'InsidePlastering' 'OutsidePlastering' 'Skirting' 'RCCinDropwall'})
     x = sum(TC, 'all');
     format short
     y= round(x);
     TotalCost = fprintf('<strong>Estimated Total Cost is %d Tk</strong>\n', y);
     disp("Thanks for staying with us")

elseif ((r1(2)+r2(2)+tw==p(2))&&(r1(1)+v(1)+tw==p(1))&&(r1(2)+r2(2)+3*tw==v(2)&&r1(1)==r2(1))) %%case-04
    temp= p(2); p(2)=p(1); p(1)=temp; %%swap the x and y dimension of plan
    temp= r1(2); r1(2)=r1(1); r1(1)=temp; %%swap the x and y dimension of room-01
    temp= r2(2); r2(2)=r2(1); r2(1)=temp; %%swap the x and y dimension of room-02
    temp= v(2); v(2)=v(1); v(1)=temp; %%swap the x and y dimension of verandah

    %%now its a condition of case 01 
    %BFS
    BFS=r1(1)*r1(2)+r2(1)*r2(2)+(v(1)-2*tw)*(v(2)-tw);

    %CC
    CC=(r1(1)*r1(2)+r2(1)*r2(2)+(v(1)-2*tw)*(v(2)-tw))*(3/12);

    d1=x(8,:); %% Dimension of door in [x z] direcction;
    n1=x(9,1); %% Number of door;
    w1=x(10,:); %% Dimension of window? [x z];
    n2=x(11,1); %% Number of window;
    sn=x(12,1); %% No of Stairs;
    sl=x(13,1); %%Length of Stairs;
    if (d1(1)*n1+w1(1)*n2)<=((r1(1)+r2(1)+3*tw)*2+(r1(2)*3))
        %Floor Finish
        FloorFinish= (r1(1)*r1(2)+r2(1)*r2(2)+v(1)*v(2)-cn*cd(1)*cd(2)+tw*d1(1)*n1+(tw+0.5)*sl* sn)*(1/(4*12));
        
        %Brickwork
        Brickwork=((r1(1)+r2(1)+3*tw)*2+(r1(2)*3))*tw*hs-d1(1)*d1(2)*tw*n1-w1(1)*w1(2)*tw*n2-((r1(1)+r2(1)+3*tw)*2+(r1(2)*3))*tw*(6/12);
        
        %RCC in column
        RCCInColumn=cd(1)*cd(2)*hs*cn;
        
        %RCC in Lintel
        RCCInLintel=((r1(1)+r2(1)+3*tw)*2+(r1(2)*3))*tw*(6/12);
        %%continuous Lintel all over the perimeter
       
    else error('Length of doors and windows must be less than perimeter')
    end
    
    %RCC in Roof
    CorD= x(14,:); %% Dimension of cornice in [x y] direction;
    CorT= x(15,1); %%input ("Thickness of Cornice?     ");
    RCCinRoof= CorD(1)*CorD(2)*CorT;
    
    %Lime Concrete in Roof
    %Bricks in Parapet
    PwHT=x(16,:); %% Height and Thickness of Parapet Wall (in [h t] format)
    O= input("Is the parapet Wall above Cornice? (Y/N)    ");
    if O=="Y"
        LimeConcreteInRoof=(CorD(1)-2*PwHT(2))*(CorD(2)-2*PwHT(2))*(3/12);
        BricksInParapet= (CorD(1)*2+((CorD(2)-PwHT(2)*2)*2))*PwHT(1)*PwHT(2);
    else
        LimeConcreteInRoof=p(1)*(p(2)-PwHT(2))*(3/12);
        BricksInParapet= 2*((p(1)+2*PwHT(2))+p(2)-tw)*PwHT(1)*PwHT(2);
    end
    
    %Brickwork in Stair
    BrS=0;
    for i=1:1:sn
        BrSu= (10/12) *(6/12)* sl*i;
        BrS= BrS+ BrSu;
    end
    BrickworkInStairs=BrS;
    
    CdN= x(17,1); %% No of Common Door
    DL= x(18,:); %% Total Dropwall Length in [x y] direction
    Dht=x(19,:); %% Height and Thickness of Dropwall? (in [h t] format)
   
    %Inside Plastering
    %sh=skirting height
    sh=10/12;
    TiP= 0.25/12; 

    rm1=2*(r1(1)+r1(2))*(hs-sh)*TiP; %for room 1
    rm2=2*(r2(1)+r2(2))*(hs-sh)*TiP; %for room 2
    vp= v(1)*(hs-sh)*TiP; %for verandah
    cp=((r1(1)*r1(2)+r2(1)*r2(2))+v(1)*v(2))*TiP; %Ceiling
    dp=(DL(1)+ 2* DL(2))*Dht(1)*TiP; %dropwall
    edge=n1*(2*(d1(2)-sh)+d1(1))*sh*TiP + n2*(2*(w1(1)+w1(2))*sh*TiP); %edge of door and window;
    %deduct
    CwN= x(20,1); %% No of Common Window between rooms and verandah;
    deduct= CwN*2*w1(1)*w1(2)*TiP+(n2-CwN)*w1(1)*w1(2)*TiP+CdN*2*d1(1)*(d1(2)-sh)*TiP+(n1-CdN)*d1(1)*(d1(2)-sh)+2*Dht(1)*Dht(2)*TiP+cn*cd(1)*cd(2)*TiP+ (DL(1)+2*DL(2))*Dht(2)*TiP;
    InsidePlastering = rm1+ rm2+ vp+ cp+ dp+ edge- deduct;
    
    %Outside Plastering
    Own= x(21,1); %% Number of Outside Window
    ToP= 0.5/12;
    OutsideWallP=(p(1)+2*tw+2*(r1(2)+2*tw))*hs*ToP-(Own*(w1(1)*w1(2)))*ToP;
    ColP= cn*2*(cd(1)+cd(2))*(hs-sh)*ToP-2*cn*Dht(1)*Dht(2)*ToP;
    DropWallP=  (DL(1)+2*DL(2))*(Dht(2)+Dht(1))*ToP;
    StP=0;
    for(i=1:1:sn)
        StPu= 2* (10/12) *(6/12)* ToP*i;
        StP= StP+ StPu;
    end
    StP;
    if O=="Y"
        PwP= 2*(CorD(1)+CorD(2))*PwHT(1)*ToP+2*(CorD(1)+CorD(2)-2*PwHT(2))*PwHT(2)*ToP+2*(CorD(1)-2*PwHT(2)+CorD(2)-2*PwHT(2))*PwHT(1)*ToP;
        CoP=2*(CorD(1)+CorD(2))*CorT*ToP+(CorD(1)-(p(1)+2*tw))*(p(2)+tw)*ToP;
    else
        PwP= 2*(p(1)+2*tw+p(2)+tw)*PwHT(1)*ToP+2*(p(1)+2*tw+p(2)-tw)*PwHT(2)*ToP+2*(p(1)+2*tw-2*PwHT(2)+p(2)+tw-2*PwHT(2))*PwHT(1)*ToP;
        CoP=2*(CorD(1)+CorD(2))*CorT*ToP+2*(CorD(1)-(p(1)+2*tw))*(p(2)+tw)*ToP;
    end
    PwP;
    CoP;
    OutsidePlastering= OutsideWallP+ColP+ DropWallP+ StP+PwP+CoP;
    
    %Skirting
    Skirting= (2*((r1(1)+r1(2))+r2(1)+r2(2)+(cd(1)+cd(2))*cn-d1(1)*CdN)+v(1)-(n1-CdN)*d1(1))*(sh)*(0.75/12);

    %RCC in Dropwall
    RCCinDropwall= (DL(1)+DL(2)*2)*Dht(1)*Dht(2);

   quantity=[BFS CC FloorFinish Brickwork RCCInColumn RCCInLintel RCCinRoof LimeConcreteInRoof BricksInParapet BrickworkInStairs InsidePlastering OutsidePlastering Skirting RCCinDropwall]';
   rate=x(1:14,5);
   TC=[quantity.*rate];
   INo=[1:14]';
     A = table([INo], [quantity],[rate],[TC],...
    'VariableNames',{'Item No' 'Quantity' 'Per Unit Cost(BDT)' 'Cost of Individual Item(BDT)'},...
    'RowNames',{'BFS' 'CC' 'FloorFinish' 'Brickwork' 'RCCInColumn' 'RCCInLintel' 'RCCinRoof' 'LimeConcreteInRoof' 'BricksInParapet' 'BrickworkInStairs' 'InsidePlastering' 'OutsidePlastering' 'Skirting' 'RCCinDropwall'})
     x = sum(TC, 'all');
     format short
     y= round(x);
     TotalCost = fprintf('<strong>Estimated Total Cost is %d Tk</strong>\n', y);
     disp("Thanks for staying with us")

elseif ((r2(2)==p(2))&&(r1(1)+r2(1)+tw==p(1))&&(r1(2)+v(2)==r2(2))&&(r1(1)==v(1)-2*tw)) %%case-05
    temp= p(2); p(2)=p(1); p(1)=temp; %%swap the x and y dimension of plan
    temp= r1(2); r1(2)=r1(1); r1(1)=temp; %%swap the x and y dimension of room-01
    temp= r2(2); r2(2)=r2(1); r2(1)=temp; %%swap the x and y dimension of room-02
    temp= v(2); v(2)=v(1); v(1)=temp; %%swap the x and y dimension of verandah
    
    %Now its a condition of Case-02
        %BFS
    BFS=r1(1)*r1(2)+r2(1)*r2(2)+(v(1)-tw)*(v(2)-tw);

    %CC
    CC=(r1(1)*r1(2)+r2(1)*r2(2)+(v(1)-tw)*(v(2)-tw))*(3/12);

    d1=x(8,:); %% Dimension of door in [x z] direcction;
    n1=x(9,1); %% Number of door;
    w1=x(10,:); %% Dimension of window? [x z];
    n2=x(11,1); %% Number of window;
    sn=x(12,1); %% No of Stairs;
    sl=x(13,1); %%Length of Stairs;
    if (d1(1)*n1+w1(1)*n2)<=((r1(1)+2*r1(2)+2*tw)+2*(r2(1)+2*tw+r2(2)))
        %Floor Finish
        FloorFinish= (r1(1)*r1(2)+r2(1)*r2(2)+v(1)*v(2)-cn*cd(1)*cd(2)+tw*d1(1)*n1+(tw+0.5)*sl* sn)*(1/(4*12)) ;
        
        %Brickwork
        Brickwork=((r1(1)+2*r1(2)+2*tw)+2*(r2(1)+2*tw+r2(2)))*tw*hs-d1(1)*d1(2)*tw*n1-w1(1)*w1(2)*tw*n2-((r1(1)+2*r1(2)+2*tw)+2*(r2(1)+2*tw+r2(2)))*tw*(6/12);
        
        %RCC in column
        RCCInColumn=cd(1)*cd(2)*hs*cn;
        
        %RCC in Lintel
        RCCInLintel=((r1(1)+2*r1(2)+2*tw)+2*(r2(1)+2*tw+r2(2)))*tw*(6/12);
        %%continuous Lintel all over the perimeter
       
    else error('Length of doors and windows must be less than perimeter')
    end
    
    %RCC in Roof
    CorD= x(14,:); %% Dimension of cornice in [x y] direction;
    CorT= x(15,1); %%input ("Thickness of Cornice?     ");
    RCCinRoof= CorD(1)*CorD(2)*CorT;
    
    %Lime Concrete in Roof
    %Bricks in Parapet
    PwHT=x(16,:); %% Height and Thickness of Parapet Wall (in [h t] format)
    O= input("Is the parapet Wall above Cornice? (Y/N)");
    if O=="Y"
        LimeConcreteInRoof=(CorD(1)-2*PwHT(2))*(CorD(2)-2*PwHT(2))*(3/12);
        BricksInParapet= (CorD(1)*2+((CorD(2)-PwHT(2)*2)*2))*PwHT(1)*PwHT(2);
    else
        LimeConcreteInRoof=p(1)*(p(2)-PwHT(2))*(3/12);
        BricksInParapet= 2*((p(1)+2*PwHT(2))+p(2)-tw)*PwHT(1)*PwHT(2);
    end
    
    %Brickwork in Stair
    BrS=0;
    for(i=1:1:sn)
        BrSu= (10/12) *(6/12)* sl*i;
        BrS= BrS+ BrSu;
    end
    BrickworkInStairs=BrS;
    
    
    CdN= x(17,1); %% No of Common Door
    DL= x(18,:); %% Total Dropwall Length in [x y] direction
    Dht=x(19,:); %% Height and Thickness of Dropwall? (in [h t] format)

    %Inside Plastering
    %sh=skirting height
    sh=10/12;
    TiP= 0.25/12; 

    rm1=2*(r1(1)+r1(2))*(hs-sh)*TiP; %for room 1
    rm2=2*(r2(1)+r2(2))*(hs-sh)*TiP; %for room 2
    vp= (v(1)+v(2))*(hs-sh)*TiP; %for verandah
    cp=((r1(1)*r1(2)+r2(1)*r2(2))+v(1)*v(2))*TiP; %Ceiling
    dp=(DL(1)+DL(2))*Dht(1)*TiP; %dropwall
    edge=n1*(2*(d1(2)-sh)+d1(1))*sh*TiP + n2*(2*(w1(1)+w1(2))*sh*TiP); %edge of door and window;
    %deduct
    CwN= x(20,1); %% No of Common Window between rooms and verandah
    deduct= CwN*2*w1(1)*w1(2)*TiP+(n2-CwN)*w1(1)*w1(2)*TiP+CdN*2*d1(1)*(d1(2)-sh)*TiP+(n1-CdN)*d1(1)*(d1(2)-sh)+2*Dht(1)*Dht(2)*TiP+cn*cd(1)*cd(2)*TiP+ (DL(1)+DL(2))*Dht(2)*TiP;
    InsidePlastering = rm1+ rm2+ vp+ cp+ dp+ edge- deduct;
    
    %Outside Plastering
    Own= x(21,1); %% Number of Outside Window;  
    ToP= 0.5/12;
    OutsideWallP=(r1(1)+2*tw+p(2)+tw+r2(1)+2*tw+r2(2)+2*tw)*hs*ToP-(Own*(w1(1)*w1(2)))*ToP;
    ColP= cn*2*(cd(1)+cd(2))*(hs-sh)*ToP-2*cn*Dht(1)*Dht(2)*ToP;
    DropWallP=  (DL(1)+DL(2))*(Dht(2)+Dht(1))*ToP;
    StP=0;
    for(i=1:1:sn)
        StPu= 2* (10/12) *(6/12)* ToP*i;
        StP= StP+ StPu;
    end
    StP;
    if O=="Y"
        PwP= 2*(CorD(1)+CorD(2))*PwHT(1)*ToP+2*(CorD(1)+CorD(2)-2*PwHT(2))*PwHT(2)*ToP+2*(CorD(1)-2*PwHT(2)+CorD(2)-2*PwHT(2))*PwHT(1)*ToP;
        CoP=2*(CorD(1)+CorD(2))*CorT*ToP+(CorD(1)-(p(1)+2*tw))*(p(2)+tw)*ToP;
    else
        PwP= 2*(p(1)+2*tw+p(2)+tw)*PwHT(1)*ToP+2*(p(1)+2*tw+p(2)-tw)*PwHT(2)*ToP+2*(p(1)+2*tw-2*PwHT(2)+P(2)+tw-2*PwHT(2))*PwHT(1)*ToP;
        CoP=2*(CorD(1)+CorD(2))*CorT*ToP+2*(CorD(1)-(p(1)+2*tw))*(p(2)+tw)*ToP;
    end
    PwP;
    OutsidePlastering= OutsideWallP+ColP+ DropWallP+ StP+PwP+CoP;
    
    %Skirting
    Skirting= (2*((r1(1)+r1(2))+r2(1)+r2(2)+(cd(1)+cd(2))*cn-d1(1)*CdN)+(v(1)+v(2))-(n1-CdN)*d1(1))*(sh)*(0.75/12);

    %RCC in Dropwall
    RCCinDropwall= (DL(1)+DL(2))*Dht(1)*Dht(2);

     quantity=[BFS CC FloorFinish Brickwork RCCInColumn RCCInLintel RCCinRoof LimeConcreteInRoof BricksInParapet BrickworkInStairs InsidePlastering OutsidePlastering Skirting RCCinDropwall]';
     rate=x(1:14,5);
     TC=[quantity.*rate];
     INo=[1:14]';
     A = table([INo], [quantity],[rate],[TC],...
    'VariableNames',{'Item No' 'Quantity' 'Per Unit Cost(BDT)' 'Cost of Individual Item(BDT)'},...
    'RowNames',{'BFS' 'CC' 'FloorFinish' 'Brickwork' 'RCCInColumn' 'RCCInLintel' 'RCCinRoof' 'LimeConcreteInRoof' 'BricksInParapet' 'BrickworkInStairs' 'InsidePlastering' 'OutsidePlastering' 'Skirting' 'RCCinDropwall'})
     x = sum(TC, 'all');
     format short
     y= round(x);
     TotalCost = fprintf('<strong>Estimated Total Cost is %d Tk</strong>\n', y);
     disp("Thanks for staying with us")

elseif ((r1(1)==p(1))&&(r1(2)+r2(2)+tw==p(2))&&(r2(1)+v(1)==r1(1))&&(r2(2)==v(2)-tw)) %%case-06 
    temp=r1; r1=r2; r2=temp; %%Replace the values of room-01 and room-02

    %Now its a condition of case 02

    %BFS
    BFS=r1(1)*r1(2)+r2(1)*r2(2)+(v(1)-tw)*(v(2)-tw);

    %CC
    CC=(r1(1)*r1(2)+r2(1)*r2(2)+(v(1)-tw)*(v(2)-tw))*(3/12);

    d1=x(8,:); %% Dimension of door in [x z] direcction;
    n1=x(9,1); %% Number of door;
    w1=x(10,:); %% Dimension of window? [x z];
    n2=x(11,1); %% Number of window;
    sn=x(12,1); %% No of Stairs;
    sl=x(13,1); %%Length of Stairs;
    if (d1(1)*n1+w1(1)*n2)<=((r1(1)+2*r1(2)+2*tw)+2*(r2(1)+2*tw+r2(2)))
        %Floor Finish
        FloorFinish= (r1(1)*r1(2)+r2(1)*r2(2)+v(1)*v(2)-cn*cd(1)*cd(2)+tw*d1(1)*n1+(tw+0.5)*sl* sn)*(1/(4*12)) ;
        
        %Brickwork
        Brickwork=((r1(1)+2*r1(2)+2*tw)+2*(r2(1)+2*tw+r2(2)))*tw*hs-d1(1)*d1(2)*tw*n1-w1(1)*w1(2)*tw*n2-((r1(1)+2*r1(2)+2*tw)+2*(r2(1)+2*tw+r2(2)))*tw*(6/12);
        
        %RCC in column
        RCCInColumn=cd(1)*cd(2)*hs*cn;
        
        %RCC in Lintel
        RCCInLintel=((r1(1)+2*r1(2)+2*tw)+2*(r2(1)+2*tw+r2(2)))*tw*(6/12);
        %%continuous Lintel all over the perimeter
       
    else error('Length of doors and windows must be less than perimeter')
    end
    
    %RCC in Roof
    CorD= x(14,:); %% Dimension of cornice in [x y] direction;
    CorT= x(15,1); %%input ("Thickness of Cornice?     ");
    RCCinRoof= CorD(1)*CorD(2)*CorT;
    
    %Lime Concrete in Roof
    %Bricks in Parapet
    PwHT=x(16,:); %% Height and Thickness of Parapet Wall (in [h t] format)
    O= input("Is the parapet Wall above Cornice? (Y/N)");
    if O=="Y"
        LimeConcreteInRoof=(CorD(1)-2*PwHT(2))*(CorD(2)-2*PwHT(2))*(3/12);
        BricksInParapet= (CorD(1)*2+((CorD(2)-PwHT(2)*2)*2))*PwHT(1)*PwHT(2);
    else
        LimeConcreteInRoof=p(1)*(p(2)-PwHT(2))*(3/12);
        BricksInParapet= 2*((p(1)+2*PwHT(2))+p(2)-tw)*PwHT(1)*PwHT(2);
    end
    
    %Brickwork in Stair
    BrS=0;
    for(i=1:1:sn)
        BrSu= (10/12) *(6/12)* sl*i;
        BrS= BrS+ BrSu;
    end
    BrickworkInStairs=BrS;
    
    
    CdN= x(17,1); %% No of Common Door
    DL= x(18,:); %% Total Dropwall Length in [x y] direction
    Dht=x(19,:); %% Height and Thickness of Dropwall? (in [h t] format)

    %Inside Plastering
    %sh=skirting height
    sh=10/12;
    TiP= 0.25/12; 

    rm1=2*(r1(1)+r1(2))*(hs-sh)*TiP; %for room 1
    rm2=2*(r2(1)+r2(2))*(hs-10/12)*TiP; %for room 2
    vp= (v(1)+v(2))*(hs-sh)*TiP; %for verandah
    cp=((r1(1)*r1(2)+r2(1)*r2(2))+v(1)*v(2))*TiP; %Ceiling
    dp=(DL(1)+DL(2))*Dht(1)*TiP; %dropwall
    edge=n1*(2*(d1(2)-sh)+d1(1))*sh*TiP + n2*(2*(w1(1)+w1(2))*sh*TiP); %edge of door and window;
    %deduct
    CwN= x(20,1); %% No of Common Window between rooms and verandah
    deduct= CwN*2*w1(1)*w1(2)*TiP+(n2-CwN)*w1(1)*w1(2)*TiP+CdN*2*d1(1)*(d1(2)-sh)*TiP+(n1-CdN)*d1(1)*(d1(2)-sh)+2*Dht(1)*Dht(2)*TiP+cn*cd(1)*cd(2)*TiP+ (DL(1)+DL(2))*Dht(2)*TiP;
    InsidePlastering = rm1+ rm2+ vp+ cp+ dp+ edge- deduct;
    
    %Outside Plastering
    Own= x(21,1); %% Number of Outside Window;  
    ToP= 0.5/12;
    OutsideWallP=(r1(1)+2*tw+p(2)+tw+r2(1)+2*tw+r2(2)+2*tw)*hs*ToP-(Own*(w1(1)*w1(2)))*ToP;
    ColP= cn*2*(cd(1)+cd(2))*(hs-sh)*ToP-2*cn*Dht(1)*Dht(2)*ToP;
    DropWallP=  (DL(1)+DL(2))*(Dht(2)+Dht(1))*ToP;
    StP=0;
    for(i=1:1:sn)
        StPu= 2* (10/12) *(6/12)* ToP*i;
        StP= StP+ StPu;
    end
    StP;
    if O=="Y"
        PwP= 2*(CorD(1)+CorD(2))*PwHT(1)*ToP+2*(CorD(1)+CorD(2)-2*PwHT(2))*PwHT(2)*ToP+2*(CorD(1)-2*PwHT(2)+CorD(2)-2*PwHT(2))*PwHT(1)*ToP;
        CoP=2*(CorD(1)+CorD(2))*CorT*ToP+(CorD(1)-(p(1)+2*tw))*(p(2)+tw)*ToP;
    else
        PwP= 2*(p(1)+2*tw+p(2)+tw)*PwHT(1)*ToP+2*(p(1)+2*tw+p(2)-tw)*PwHT(2)*ToP+2*(p(1)+2*tw-2*PwHT(2)+P(2)+tw-2*PwHT(2))*PwHT(1)*ToP;
        CoP=2*(CorD(1)+CorD(2))*CorT*ToP+2*(CorD(1)-(p(1)+2*tw))*(p(2)+tw)*ToP;
    end
    PwP;
    OutsidePlastering= OutsideWallP+ColP+ DropWallP+ StP+PwP+CoP;
    
    %Skirting
    Skirting= (2*((r1(1)+r1(2))+r2(1)+r2(2)+(cd(1)+cd(2))*cn-d1(1)*CdN)+(v(1)+v(2))-(n1-CdN)*d1(1))*(sh)*(0.75/12);

    %RCC in Dropwall
    RCCinDropwall= (DL(1)+DL(2))*Dht(1)*Dht(2);

     quantity=[BFS CC FloorFinish Brickwork RCCInColumn RCCInLintel RCCinRoof LimeConcreteInRoof BricksInParapet BrickworkInStairs InsidePlastering OutsidePlastering Skirting RCCinDropwall]';
     rate=x(1:14,5);
     TC=[quantity.*rate];
     INo=[1:14]';
     A = table([INo], [quantity],[rate],[TC],...
    'VariableNames',{'Item No' 'Quantity' 'Per Unit Cost(BDT)' 'Cost of Individual Item(BDT)'},...
    'RowNames',{'BFS' 'CC' 'FloorFinish' 'Brickwork' 'RCCInColumn' 'RCCInLintel' 'RCCinRoof' 'LimeConcreteInRoof' 'BricksInParapet' 'BrickworkInStairs' 'InsidePlastering' 'OutsidePlastering' 'Skirting' 'RCCinDropwall'})
     x = sum(TC, 'all');
     format short
     y= round(x);
     TotalCost = fprintf('<strong>Estimated Total Cost is %d Tk</strong>\n', y);
     disp("Thanks for staying with us")


else disp ("Sorry, Your inputs do not match with our conditions")

end