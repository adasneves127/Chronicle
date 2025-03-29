CREATE TABLE OPERATORS (
    operatorID varchar(30) primary key,
    firstName varchar(30),
    lastName varchar(30),


    addedBy varchar(30) REFERENCES OPERATORS(operatorID),
    addedDt timestamp,
    updateBy varchar(30) REFERENCES OPERATORS(operatorID),
    updateDt timestamp
);

CREATE TABLE BUILDINGS (
    buildingID int primary key auto_increment,



    addedBy varchar(30) REFERENCES OPERATORS(operatorID),
    addedDt timestamp,
    updateBy varchar(30) REFERENCES OPERATORS(operatorID),
    updateDt timestamp
);

CREATE TABLE ROOMS (
    roomID int primary key auto_increment,



    addedBy varchar(30) REFERENCES OPERATORS(operatorID),
    addedDt timestamp,
    updateBy varchar(30) REFERENCES OPERATORS(operatorID),
    updateDt timestamp
);

CREATE TABLE STATUSES (
    statusID int primary key auto_increment,
    statusDescription varchar(50),


    addedBy varchar(30) REFERENCES OPERATORS(operatorID),
    addedDt timestamp,
    updateBy varchar(30) REFERENCES OPERATORS(operatorID),
    updateDt timestamp
);

CREATE TABLE RESERVATIONS (
    reservationID int primary key auto_increment,
    reservationName varchar(100),
    reservationStatusID int references STATUSES(statusID),

    addedBy varchar(30) REFERENCES OPERATORS(operatorID),
    addedDt timestamp,
    updateBy varchar(30) REFERENCES OPERATORS(operatorID),
    updateDt timestamp
);

CREATE TABLE BOOKINGS (
    bookingID int primary key auto_increment,
    reservationID int not null references RESERVATIONS(reservationID),
    bookingName varchar(100),
    bookingStatusID int references STATUSES(statusID),


    addedBy varchar(30) REFERENCES OPERATORS(operatorID),
    addedDt timestamp,
    updateBy varchar(30) REFERENCES OPERATORS(operatorID),
    updateDt timestamp
);

CREATE TABLE WIN_FORMS (
    winFormID int not null primary key auto_increment,
    windowInitialText varchar(50),
    dllData blob,
    addedBy varchar(30) REFERENCES OPERATORS(operatorID),
    addedDt timestamp,
    updateBy varchar(30) REFERENCES OPERATORS(operatorID),
    updateDt timestamp
);

CREATE TABLE MENU_ITEMS (
    menuItemID int not null primary key auto_increment,
    parentID int references MENU_ITEMS(menuItemID),
    label varchar(100),
    winFormID int references WIN_FORMS(winFormID),
    addedBy varchar(30) REFERENCES OPERATORS(operatorID),
    addedDt timestamp,
    updateBy varchar(30) REFERENCES OPERATORS(operatorID),
    updateDt timestamp
);

