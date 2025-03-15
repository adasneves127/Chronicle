create table OPERATORS
(
    operatorID varchar(30)                           not null
        primary key,
    password   varchar(120)                          null,
    addedBy    varchar(30)                           null,
    addedDt    timestamp default current_timestamp() null,
    updatedBy  varchar(30)                           null,
    updatedDt  timestamp default current_timestamp() null on update current_timestamp(),
    constraint foreign key (addedBy) references OPERATORS (operatorID),
    constraint foreign key (updatedBy) references OPERATORS (operatorID)
);
create table BOOKING_DETAIL_CATEGORIES
(
    bookingDetailCategoryID int auto_increment
        primary key,
    categoryName            varchar(30)                           null,
    addedBy                 varchar(30)                           null,
    addedDt                 timestamp default current_timestamp() null,
    updatedBy               varchar(30)                           null,
    updatedDt               timestamp default current_timestamp() null on update current_timestamp(),
    constraint foreign key (addedBy) references OPERATORS (operatorID),
    constraint foreign key (updatedBy) references OPERATORS (operatorID)
);
create table BOOKING_DETAILS
(
    bookingDetailID            int auto_increment
        primary key,
    bookingDetailCategoryID    int                                   not null,
    resourceName               tinytext                              null,
    defaultNotes               text                                  null,
    defaultSpecialInstructions text                                  null,
    allowNoteEdit              tinyint(1)                            null,
    allowSIEdit                tinyint(1)                            null,
    addedBy                    varchar(30)                           null,
    addedDt                    timestamp default current_timestamp() null,
    updatedBy                  varchar(30)                           null,
    updatedDt                  timestamp default current_timestamp() null on update current_timestamp(),
    constraint foreign key (bookingDetailCategoryID) references BOOKING_DETAIL_CATEGORIES (bookingDetailCategoryID),
    constraint foreign key (addedBy) references OPERATORS (operatorID),
    constraint foreign key (updatedBy) references OPERATORS (operatorID)
);
create table BUILDINGS
(
    buildingID   int auto_increment
        primary key,
    buildingCode varchar(30)                           null,
    buildingName varchar(50)                           null,
    isActive     tinyint(1)                            null,
    addedBy      varchar(30)                           null,
    addedDt      timestamp default current_timestamp() null,
    updatedBy    varchar(30)                           null,
    updatedDt    timestamp default current_timestamp() null on update current_timestamp(),
    constraint foreign key (addedBy) references OPERATORS (operatorID),
    constraint foreign key (updatedBy) references OPERATORS (operatorID)
);
create table BUILDING_HOURS
(
    buildingHourID int auto_increment
        primary key,
    buildingID     int                                      not null,
    startDate      date                                     null,
    isException    tinyint(1)                               null,
    exceptionTo    int                                      null
        check (`isException` <> 0),
    isClosed       int                                      null
        check (`isClosed` = 1 and `buildingOpen` is null and `buildingClose` is null),
    buildingOpen   time                                     null,
    buildingClose  time                                     null,
    dayOfWeek      enum ('U', 'M', 'T', 'W', 'R', 'F', 'S') null,
    addedBy        varchar(30)                              null,
    addedDt        timestamp default current_timestamp()    null,
    updatedBy      varchar(30)                              null,
    updatedDt      timestamp default current_timestamp()    null on update current_timestamp(),
    constraint buildingID
        unique (buildingID, startDate),
    constraint foreign key (exceptionTo) references BUILDING_HOURS (buildingHourID),
    constraint foreign key (addedBy) references OPERATORS (operatorID),
    constraint foreign key (updatedBy) references OPERATORS (operatorID)
);
create table CLASSES
(
    classID   varchar(30)                           not null
        primary key,
    className varchar(100)                          null,
    addedBy   varchar(30)                           null,
    addedDt   timestamp default current_timestamp() null,
    updatedBy varchar(30)                           null,
    updatedDt timestamp default current_timestamp() null on update current_timestamp(),
    constraint foreign key (addedBy) references OPERATORS (operatorID),
    constraint foreign key (updatedBy) references OPERATORS (operatorID)
);
create table CLASS_OPERATOR_LINK
(
    operatorClassID int auto_increment
        primary key,
    operatorID      varchar(30)                           null,
    classID         varchar(30)                           null,
    addedBy         varchar(30)                           null,
    addedDt         timestamp default current_timestamp() null,
    updatedBy       varchar(30)                           null,
    updatedDt       timestamp default current_timestamp() null on update current_timestamp(),
    constraint foreign key (operatorID) references OPERATORS (operatorID),
    constraint foreign key (classID) references CLASSES (classID),
    constraint foreign key (addedBy) references OPERATORS (operatorID),
    constraint foreign key (updatedBy) references OPERATORS (operatorID)
);
create table COLOR_PALETTES
(
    paletteID          int auto_increment
        primary key,
    paletteDescription varchar(100)                          null,
    isGlobal           tinyint(1)                            null,
    addedBy            varchar(30)                           null,
    addedDt            timestamp default current_timestamp() null,
    updatedBy          varchar(30)                           null,
    updatedDt          timestamp default current_timestamp() null on update current_timestamp(),
    constraint foreign key (addedBy) references OPERATORS (operatorID),
    constraint foreign key (updatedBy) references OPERATORS (operatorID)
);
create table CONTACTS
(
    contactID int auto_increment
        primary key,
    addedBy   varchar(30)                           null,
    addedDt   timestamp default current_timestamp() null,
    updatedBy varchar(30)                           null,
    updatedDt timestamp default current_timestamp() null on update current_timestamp(),
    constraint foreign key (addedBy) references OPERATORS (operatorID),
    constraint foreign key (updatedBy) references OPERATORS (operatorID)
);
create table CONTACT_ATTRIBUTE_TYPES
(
    contactAttributeTypeID   int auto_increment
        primary key,
    contactAttributeTypeDesc varchar(30)                           null,
    addedBy                  varchar(30)                           null,
    addedDt                  timestamp default current_timestamp() null,
    updatedBy                varchar(30)                           null,
    updatedDt                timestamp default current_timestamp() null on update current_timestamp(),
    constraint foreign key (addedBy) references OPERATORS (operatorID),
    constraint foreign key (updatedBy) references OPERATORS (operatorID)
);
create table CONTACT_ATTRIBUTES
(
    sponsorAttributeID     int auto_increment
        primary key,
    contactID              int          not null,
    contactAttributeTypeID int          not null,
    contactAttributeText   varchar(100) null,
    constraint foreign key (contactID) references CONTACTS (contactID),
    constraint foreign key (contactAttributeTypeID) references CONTACT_ATTRIBUTE_TYPES (contactAttributeTypeID),
    constraint unique (contactID, contactAttributeTypeID)
);
create table DESKTOP_FORMS
(
    desktopFormID int auto_increment
        primary key,
    formName      varchar(50)                           null,
    addedBy       varchar(30)                           null,
    addedDt       timestamp default current_timestamp() null,
    updatedBy     varchar(30)                           null,
    updatedDt     timestamp default current_timestamp() null on update current_timestamp(),
    constraint foreign key (addedBy) references OPERATORS (operatorID),
    constraint foreign key (updatedBy) references OPERATORS (operatorID)
);
create table DESKTOP_FORM_CONTROLS
(
    desktopFormControlID int auto_increment
        primary key,
    desktopFormID        int                                   not null,
    controlType          int                                   not null,
    addedBy              varchar(30)                           null,
    addedDt              timestamp default current_timestamp() null,
    updatedBy            varchar(30)                           null,
    updatedDt            timestamp default current_timestamp() null on update current_timestamp(),
    constraint foreign key (addedBy) references OPERATORS (operatorID),
    constraint foreign key (updatedBy) references OPERATORS (operatorID),
    constraint foreign key (desktopFormID) references DESKTOP_FORMS (desktopFormID)
);
create table EVENT_TYPE
(
    eventTypeID   int auto_increment
        primary key,
    eventTypeText varchar(30)                           null,
    addedBy       varchar(30)                           null,
    addedDt       timestamp default current_timestamp() null,
    updatedBy     varchar(30)                           null,
    updatedDt     timestamp default current_timestamp() null on update current_timestamp(),
    constraint foreign key (addedBy) references OPERATORS (operatorID),
    constraint foreign key (updatedBy) references OPERATORS (operatorID)
);
create table MENU_STRIP_TABS
(
    menuStripTabID   int auto_increment
        primary key,
    menuStripTabText varchar(30)                           null,
    addedBy          varchar(30)                           null,
    addedDt          timestamp default current_timestamp() null,
    updatedBy        varchar(30)                           null,
    updatedDt        timestamp default current_timestamp() null on update current_timestamp(),
    constraint foreign key (addedBy) references OPERATORS (operatorID),
    constraint foreign key (updatedBy) references OPERATORS (operatorID)
);
create table MENU_STRIP_ITEMS
(
    menuStripItemID int auto_increment
        primary key,
    menuStripTabID  int                                   not null,
    targetForm      int                                   not null,
    addedBy         varchar(30)                           null,
    addedDt         timestamp default current_timestamp() null,
    updatedBy       varchar(30)                           null,
    updatedDt       timestamp default current_timestamp() null on update current_timestamp(),
    constraint foreign key (menuStripTabID) references MENU_STRIP_TABS (menuStripTabID),
    constraint foreign key (addedBy) references OPERATORS (operatorID),
    constraint foreign key (updatedBy) references OPERATORS (operatorID)
);
create table MENU_STRIP_CLASS_AUTH
(
    menuStripClassAuthID int auto_increment
        primary key,
    classID              varchar(30)                           not null,
    menuStripItemID      int                                   not null,
    granted              tinyint(1)                            null,
    addedBy              varchar(30)                           null,
    addedDt              timestamp default current_timestamp() null,
    updatedBy            varchar(30)                           null,
    updatedDt            timestamp default current_timestamp() null on update current_timestamp(),
    constraint foreign key (classID) references CLASSES (classID),
    constraint foreign key (menuStripItemID) references MENU_STRIP_ITEMS (menuStripItemID),
    constraint foreign key (addedBy) references OPERATORS (operatorID),
    constraint foreign key (updatedBy) references OPERATORS (operatorID)
);

create table OPERATOR_ACCESS_TOKENS
(
    operatorAccessTokenID varchar(36)                           not null
        primary key,
    operatorID            varchar(30)                           not null,
    createdDT             timestamp default current_timestamp() not null,
    expireDT              timestamp default current_timestamp() not null,
    constraint foreign key (operatorID) references OPERATORS (operatorID)
);
create table PERMISSION_NAMES
(
    permissionName varchar(30)                           not null
        primary key,
    addedBy        varchar(30)                           null,
    addedDt        timestamp default current_timestamp() null,
    updatedBy      varchar(30)                           null,
    updatedDt      timestamp default current_timestamp() null on update current_timestamp(),
    constraint foreign key (addedBy) references OPERATORS (operatorID),
    constraint foreign key (updatedBy) references OPERATORS (operatorID)
);
create table CLASS_PERMISSIONS
(
    classPermissionID int auto_increment
        primary key,
    classID           varchar(30)                           not null,
    permissionName    varchar(30)                           not null,
    addedBy           varchar(30)                           null,
    addedDt           timestamp default current_timestamp() null,
    updatedBy         varchar(30)                           null,
    updatedDt         timestamp default current_timestamp() null on update current_timestamp(),
    constraint foreign key (classID) references CLASSES (classID),
    constraint foreign key (permissionName) references PERMISSION_NAMES (permissionName),
    constraint foreign key (addedBy) references OPERATORS (operatorID),
    constraint foreign key (updatedBy) references OPERATORS (operatorID)
);
create table PROCESS_LOG
(
    processLogID    int auto_increment
        primary key,
    levelName       enum ('CRITICAL', 'FATAL', 'ERROR', 'WARNING', 'INFO', 'DEBUG') null,
    loggerName      varchar(30)                                                     not null,
    logMessage      text                                                            not null,
    filePath        text                                                            not null,
    fileName        varchar(50)                                                     null,
    moduleName      varchar(50)                                                     null,
    excInfo         text                                                            null,
    excText         text                                                            null,
    stackInfo       text                                                            null,
    lineno          int                                                             null,
    funcName        varchar(50)                                                     null,
    dateTime        timestamp                                                       null,
    msecs           float                                                           null,
    relativeCreated float                                                           null,
    threadID        mediumtext                                                      null,
    threadName      text                                                            null,
    processName     text                                                            null,
    processID       int                                                             null,
    taskName        text                                                            null
);
create table PROCESS_LOG_REQUESTS
(
    processLogRequestID int auto_increment
        primary key,
    processLogID        int                                                                            null,
    method              enum ('GET', 'POST', 'HEAD', 'TRACE', 'OPTIONS', 'CONNECT', 'PATCH', 'DELETE') null,
    scheme              varchar(5)                                                                     null,
    serverInfo          varchar(30)                                                                    null,
    root_path           text                                                                           null,
    path                text                                                                           null,
    query_string        text                                                                           null,
    remote_addr         varchar(15)                                                                    null,
    shallow             tinyint(1)                                                                     null,
    host                text                                                                           null,
    urlrule             text                                                                           null,
    viewArgs            text                                                                           null,
    url                 text                                                                           null,
    constraint foreign key (processLogID) references PROCESS_LOG (processLogID)
            on delete cascade
);
create table PROCESS_LOG_REQUEST_ENVIRON
(
    processLogRequestEnvironID int auto_increment
        primary key,
    processLogRequestID        int         not null,
    environName                varchar(30) null,
    environValue               text        null,
    constraint foreign key (processLogRequestID) references PROCESS_LOG_REQUESTS (processLogRequestID)
            on delete cascade
);
create table PROCESS_LOG_REQUEST_HEADERS
(
    processLogRequestHeaderID int auto_increment
        primary key,
    processLogRequestID       int         not null,
    headerName                varchar(30) null,
    headerValue               text        null,
    constraint foreign key (processLogRequestID) references PROCESS_LOG_REQUESTS (processLogRequestID)
            on delete cascade
);
create table RESERVATIONS
(
    reservationID int auto_increment
        primary key,
    addedBy       varchar(30)                           null,
    addedDt       timestamp default current_timestamp() null,
    updatedBy     varchar(30)                           null,
    updatedDt     timestamp default current_timestamp() null on update current_timestamp(),
    constraint foreign key (addedBy) references OPERATORS (operatorID),
    constraint foreign key (updatedBy) references OPERATORS (operatorID)
);
create table BOOKINGS
(
    bookingID     int auto_increment
        primary key,
    reservationID int                                   not null,
    addedBy       varchar(30)                           null,
    addedDt       timestamp default current_timestamp() null,
    updatedBy     varchar(30)                           null,
    updatedDt     timestamp default current_timestamp() null on update current_timestamp(),
    constraint foreign key (reservationID) references RESERVATIONS (reservationID),
    constraint foreign key (addedBy) references OPERATORS (operatorID),
    constraint foreign key (updatedBy) references OPERATORS (operatorID)
);
create table ASSIGNED_BOOKING_RESOURCE_CATEGORIES
(
    assignedBookingResourceCategoryID int auto_increment
        primary key,
    bookingID                         int                                   not null,
    addedBy                           varchar(30)                           null,
    addedDt                           timestamp default current_timestamp() null,
    updatedBy                         varchar(30)                           null,
    updatedDt                         timestamp default current_timestamp() null on update current_timestamp(),
    constraint foreign key (bookingID) references BOOKINGS (bookingID),
    constraint foreign key (addedBy) references OPERATORS (operatorID),
    constraint foreign key (updatedBy) references OPERATORS (operatorID)
);
create table ASSIGNED_BOOKING_RESOURCES
(
    assignedBookingResourceID         int auto_increment
        primary key,
    assignedBookingResourceCategoryID int                                   not null,
    bookingDetailID                   int                                   not null,
    noteText                          text                                  null,
    specialInstructionText            text                                  null,
    addedBy                           varchar(30)                           null,
    addedDt                           timestamp default current_timestamp() null,
    updatedBy                         varchar(30)                           null,
    updatedDt                         timestamp default current_timestamp() null on update current_timestamp(),
    constraint foreign key (assignedBookingResourceCategoryID) references ASSIGNED_BOOKING_RESOURCE_CATEGORIES (assignedBookingResourceCategoryID),
    constraint foreign key (bookingDetailID) references BOOKING_DETAILS (bookingDetailID),
    constraint foreign key (addedBy) references OPERATORS (operatorID),
    constraint foreign key (updatedBy) references OPERATORS (operatorID)
);
create table DELETED_BOOKING_RESOURCE_CATEGORIES
(
    deletedBookingResourceCategoryID int auto_increment
        primary key,
    bookingID                        int                                   not null,
    addedBy                          varchar(30)                           null,
    addedDt                          timestamp default current_timestamp() null,
    updatedBy                        varchar(30)                           null,
    updatedDt                        timestamp default current_timestamp() null on update current_timestamp(),
    constraint foreign key (bookingID) references BOOKINGS (bookingID),
    constraint foreign key (addedBy) references OPERATORS (operatorID),
    constraint foreign key (updatedBy) references OPERATORS (operatorID)
);
create table DELETED_BOOKING_RESOURCES
(
    deletedBookingResourceID         int auto_increment
        primary key,
    deletedBookingResourceCategoryID int                                   not null,
    bookingDetailID                  int                                   not null,
    noteText                         text                                  null,
    specialInstructionText           text                                  null,
    addedBy                          varchar(30)                           null,
    addedDt                          timestamp default current_timestamp() null,
    updatedBy                        varchar(30)                           null,
    updatedDt                        timestamp default current_timestamp() null on update current_timestamp(),
    constraint foreign key (deletedBookingResourceCategoryID) references DELETED_BOOKING_RESOURCE_CATEGORIES (deletedBookingResourceCategoryID),
    constraint foreign key (bookingDetailID) references BOOKING_DETAILS (bookingDetailID),
    constraint foreign key (addedBy) references OPERATORS (operatorID),
    constraint foreign key (updatedBy) references OPERATORS (operatorID)
);

create table ROOMS
(
    roomID          int auto_increment
        primary key,
    roomDescription varchar(30)                           null,
    buildingID      int                                   not null,
    addedBy         varchar(30)                           null,
    addedDt         timestamp default current_timestamp() null,
    updatedBy       varchar(30)                           null,
    updatedDt       timestamp default current_timestamp() null on update current_timestamp(),
    constraint foreign key (buildingID) references BUILDINGS (buildingID),
    constraint foreign key (addedBy) references OPERATORS (operatorID),
    constraint foreign key (updatedBy) references OPERATORS (operatorID)
);
create table SETUP_TYPE
(
    setupTypeID      int auto_increment
        primary key,
    setupDescription varchar(30)                           null,
    addedBy          varchar(30)                           null,
    addedDt          timestamp default current_timestamp() null,
    updatedBy        varchar(30)                           null,
    updatedDt        timestamp default current_timestamp() null on update current_timestamp(),
    constraint foreign key (addedBy) references OPERATORS (operatorID),
    constraint foreign key (updatedBy) references OPERATORS (operatorID)
);
create table MAX_SETUP
(
    maxSetupID  int auto_increment
        primary key,
    roomID      int                                   not null,
    setupTypeID int                                   not null,
    setupCount  int                                   not null
        check (`setupCount` >= 0),
    addedBy     varchar(30)                           null,
    addedDt     timestamp default current_timestamp() null,
    updatedBy   varchar(30)                           null,
    updatedDt   timestamp default current_timestamp() null on update current_timestamp(),
    constraint foreign key (roomID) references ROOMS (roomID),
    constraint foreign key (setupTypeID) references SETUP_TYPE (setupTypeID),
    constraint foreign key (addedBy) references OPERATORS (operatorID),
    constraint foreign key (updatedBy) references OPERATORS (operatorID)
);
create table SPONSORS
(
    sponsorID   int auto_increment
        primary key,
    sponsorName varchar(30)                           null,
    addedBy     varchar(30)                           null,
    addedDt     timestamp default current_timestamp() null,
    updatedBy   varchar(30)                           null,
    updatedDt   timestamp default current_timestamp() null on update current_timestamp(),
    constraint foreign key (addedBy) references OPERATORS (operatorID),
    constraint foreign key (updatedBy) references OPERATORS (operatorID)
);
create table CONTACT_SPONSOR_LINK
(
    sponsorLinkID int auto_increment
        primary key,
    sponsorID     int                                   not null,
    contactID     int                                   not null,
    addedBy       varchar(30)                           null,
    addedDt       timestamp default current_timestamp() null,
    updatedBy     varchar(30)                           null,
    updatedDt     timestamp default current_timestamp() null on update current_timestamp(),
    constraint foreign key (sponsorID) references SPONSORS (sponsorID),
    constraint foreign key (contactID) references CONTACTS (contactID),
    constraint foreign key (addedBy) references OPERATORS (operatorID),
    constraint foreign key (updatedBy) references OPERATORS (operatorID)
);
create table LOCATIONS
(
    locationID          int auto_increment
        primary key,
    locationDescription varchar(30)                           null,
    buildingID          int                                   not null,
    ownerID             int                                   null,
    addedBy             varchar(30)                           null,
    addedDt             timestamp default current_timestamp() null,
    updatedBy           varchar(30)                           null,
    updatedDt           timestamp default current_timestamp() null on update current_timestamp(),
    constraint foreign key (buildingID) references BUILDINGS (buildingID),
    constraint foreign key (ownerID) references SPONSORS (sponsorID),
    constraint foreign key (addedBy) references OPERATORS (operatorID),
    constraint foreign key (updatedBy) references OPERATORS (operatorID)
);
create table LOCATION_ROOM_LINK
(
    roomLinkID int auto_increment
        primary key,
    roomID     int                                   not null,
    locationID int                                   not null,
    addedBy    varchar(30)                           null,
    addedDt    timestamp default current_timestamp() null,
    updatedBy  varchar(30)                           null,
    updatedDt  timestamp default current_timestamp() null on update current_timestamp(),
    constraint foreign key (roomID) references ROOMS (roomID),
    constraint foreign key (locationID) references LOCATIONS (locationID),
    constraint foreign key (addedBy) references OPERATORS (operatorID),
    constraint foreign key (updatedBy) references OPERATORS (operatorID)
);
create table SPONSOR_ATTRIBUTE_TYPES
(
    sponsorAttributeTypeID   int auto_increment
        primary key,
    sponsorAttributeTypeDesc varchar(30)                           null,
    addedBy                  varchar(30)                           null,
    addedDt                  timestamp default current_timestamp() null,
    updatedBy                varchar(30)                           null,
    updatedDt                timestamp default current_timestamp() null on update current_timestamp(),
    constraint foreign key (addedBy) references OPERATORS (operatorID),
    constraint foreign key (updatedBy) references OPERATORS (operatorID)
);
create table SPONSOR_ATTRIBUTES
(
    sponsorAttributeID     int auto_increment
        primary key,
    sponsorID              int          not null,
    sponsorAttributeTypeID int          not null,
    sponsorAttributeText   varchar(100) null,
    constraint foreign key (sponsorID) references SPONSORS (sponsorID),
    constraint foreign key (sponsorAttributeTypeID) references SPONSOR_ATTRIBUTE_TYPES (sponsorAttributeTypeID)
);
create table STATUSES
(
    statusID   int auto_increment
        primary key,
    statusText varchar(30)                           null,
    addedBy    varchar(30)                           null,
    addedDt    timestamp default current_timestamp() null,
    updatedBy  varchar(30)                           null,
    updatedDt  timestamp default current_timestamp() null on update current_timestamp(),
    constraint foreign key (addedBy) references OPERATORS (operatorID),
    constraint foreign key (updatedBy) references OPERATORS (operatorID)
);
create table COLOR_PALETTE_STATUS_COLORS
(
    colorPaletteStatusColorID int auto_increment
        primary key,
    paletteID                 int                                   not null,
    statusID                  int                                   not null,
    argbValue                 int                                   not null,
    addedBy                   varchar(30)                           null,
    addedDt                   timestamp default current_timestamp() null,
    updatedBy                 varchar(30)                           null,
    updatedDt                 timestamp default current_timestamp() null on update current_timestamp(),
    constraint paletteID
        unique (paletteID, statusID),
    constraint foreign key (paletteID) references COLOR_PALETTES (paletteID),
    constraint foreign key (statusID) references STATUSES (statusID),
    constraint foreign key (addedBy) references OPERATORS (operatorID),
    constraint foreign key (updatedBy) references OPERATORS (operatorID)
);
create table WEB_ENDPOINTS
(
    webEndpointID int auto_increment
        primary key,
    pageURL       varchar(100)                                                                          not null,
    httpMethod    enum ('GET', 'HEAD', 'POST', 'PUT', 'DELETE', 'CONNECT', 'OPTIONS', 'TRACE', 'PATCH') null,
    allowGuest    tinyint(1)                                                                            not null,
    addedBy       varchar(30)                                                                           null,
    addedDt       timestamp default current_timestamp()                                                 null,
    updatedBy     varchar(30)                                                                           null,
    updatedDt     timestamp default current_timestamp()                                                 null on update current_timestamp(),
    constraint foreign key (addedBy) references OPERATORS (operatorID),
    constraint foreign key (updatedBy) references OPERATORS (operatorID)
);
create table PAGE_PERMISSIONS
(
    classPagePermissionID int auto_increment
        primary key,
    permissionName        varchar(30)                           not null,
    webEndpointID         int                                   not null,
    addedBy               varchar(30)                           null,
    addedDt               timestamp default current_timestamp() null,
    updatedBy             varchar(30)                           null,
    updatedDt             timestamp default current_timestamp() null on update current_timestamp(),
    constraint foreign key (permissionName) references PERMISSION_NAMES (permissionName),
    constraint foreign key (webEndpointID) references WEB_ENDPOINTS (webEndpointID)
            on delete cascade,
    constraint foreign key (addedBy) references OPERATORS (operatorID),
    constraint foreign key (updatedBy) references OPERATORS (operatorID)
);

