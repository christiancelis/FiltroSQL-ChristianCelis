create database gourmetDelight;
use gourmetDelight;


create table Clientes(
    id int primary key AUTO_INCREMENT,
    nombre varchar(100) not null,
    correo_electronico varchar(100) not null,
    telefono varchar(15) not null,
    fecha_registro date not null
);

create table Pedidos(
    id int primary key AUTO_INCREMENT,
    id_cliente int,
    fecha date not null,
    total decimal(10,2) not NULL,
    Foreign Key (id_cliente) REFERENCES Clientes(id)
);


create table Menus(
    id int primary key AUTO_INCREMENT,
    nombre varchar(100) not null,
    descripcion text not null,
    precio decimal(10,2) not null
);


create table DetallesPedidos(
    id_pedido int,
    id_menu int,
    primary key(id_pedido,id_menu),
    cantidad int not null,
    precio_unitario decimal(10,2) not NULL,
Foreign Key (id_pedido) REFERENCES Pedidos(id),
Foreign Key (id_menu) REFERENCES Menus(id)
);





