# FiltroSQL-ChristianCelis


## Consultas

1. Obtener la lista de todos los menús con sus precios

    ``` sql
    select nombre, precio
    from Menus;
    ```

2. Encontrar todos los pedidos realizados por el cliente 'Juan Perez' id fecha total

    ``` sql
    SELECT pd.id,pd.fecha,pd.total
    from Pedidos as pd 
    inner join Clientes as cli on cli.id=pd.id_cliente
    where cli.nombre="Juan Perez";
    ``` 

3. Listar los detalles de todos los pedidos, incluyendo el nombre del menú, cantidad y precio unitario pedido id. ,menu. cantidad, precio unitario

    ```sql
    SELECT dtpd.id_pedido, mn.nombre, dtpd.cantidad, dtpd.precio_unitario
    from DetallesPedidos as dtpd
    inner join Menus as mn on mn.id=dtpd.id_menu;
    ``` 

4. Calcular el total gastado por cada cliente en todos sus pedidos nombre, total gastado

    ```sql 
    select cli.nombre, sum(pd.total)
    from Clientes AS cli
    inner join Pedidos as pd on pd.id_cliente= cli.id
    group by cli.nombre;
    ``` 

5. Encontrar los menús con un precio mayor a $10

    ```sql
    SELECT mn.nombre, mn.precio
    from Menus as mn  
    where mn.precio> 10;
    ``` 

6. Obtener el menú más caro pedido al menos una vez

    ```sql
    SELECT me.nombre, me.precio
    from Menus as me
    where (me.id,me.precio) in (select me.id,max(mn.precio) from Menus as mn
    inner join DetallesPedidos as dtpd on dtpd.id_menu=mn.id
    where dtpd.cantidad>=1 );
    ``` 


7. Listar los clientes que han realizado más de un pedido
    ```sql 
    select cli.nombre, cli.correo_electronico
    from Clientes as cli
    inner join Pedidos as pd on pd.id_cliente=cli.id 
    GROUP BY cli.nombre,cli.correo_electronico
    having count(pd.id)>1;
    ``` 


8. Obtener el cliente con el mayor gasto total
    ```sql
    select cli.nombre as Nombre,sum(pd.total) as Total
    from Clientes as cli 
    inner join Pedidos as pd on pd.id_cliente=cli.id
    group by cli.nombre
    order by Total desc
    limit 1;
    ``` 

9. Mostrar el pedido más reciente de cada cliente nombre, fecha, total 

    ```sql 
    select cli.nombre, pe.fecha, pe.total
    from Clientes as cli
    inner join Pedidos as pe on pe.id_cliente=cli.id
    where (cli.id,pe.fecha) in
    (select cli.id, max(pd.fecha)
    from Pedidos as pd where pd.id_cliente=cli.id);
    ``` 

10. Obtener el detalle de pedidos (menús y cantidades) para el cliente 'Juan Perez'. id nombre menu, cantidad, precio Unitario

```sql 
Select dtpd.id_pedido, mn.nombre, dtpd.cantidad, dtpd.precio_unitario
from Clientes as cli 
inner join Pedidos as pd on pd.id_cliente=cli.id
inner join DetallesPedidos as dtpd on dtpd.id_pedido=pd.id 
inner join Menus as mn on mn.id=dtpd.id_menu
where cli.nombre= "Juan Perez";
``` 

## Procedimientos;


1. Enunciado: Crea un procedimiento almacenado llamado AgregarCliente que reciba como parámetros el nombre, correo electrónico, teléfono y fecha de registro de un nuevo cliente y lo inserte en la tabla Clientes .

    ```sql 
    delimiter $$
        create procedure AgregarCliente
        (
            in nombre varchar(100),
            in correo varchar(100),
            in telefono varchar(15)
        )
        BEGIN
            declare mensaje varchar(100);
            
            insert into Clientes VALUES(null,nombre,correo,telefono,date(CURDATE()));


            if(ROW_COUNT()>0) THEN
                set mensaje = "Cliente Creado Correctamente";
            else 
                set mensaje = "Error al crear el cliente";
            end if;

            select mensaje;
        end$$
    call AgregarCliente("Esteban Alonzo", "estebitan83@gmail.com","3332123");

    delimiter ;
    ```

2. Enunciado: Crea un procedimiento almacenado llamado ObtenerDetallesPedido que reciba como parámetro el ID del pedido y devuelva los detalles del pedido, incluyendo el nombre del menú, cantidad y precio unitario.

    ```sql
    delimiter $$

    create procedure ObtenerDetallesPedido( in idPedido int)
    begin
        Select dtpd.id_pedido, mn.nombre, dtpd.cantidad, dtpd.precio_unitario
        from  Pedidos as pd
        inner join DetallesPedidos as dtpd on dtpd.id_pedido=pd.id 
        inner join Menus as mn on mn.id=dtpd.id_menu
        where pd.id=idPedido;
    end$$
    delimiter ;
    call ObtenerDetallesPedido(2);
    ``` 



3. Enunciado: Crea un procedimiento almacenado llamado ActualizarPrecioMenu que reciba como parámetros el ID del menú y el nuevo precio, y actualice el precio del menú en la tabla Menus .

    ```sql
    delimiter $$
        create procedure ActualizarPrecioMenu(
            in idMenu int, 
            in nuevoPrecio decimal(10,2)
            )
        begin
            declare mensaje varchar(100);

            update Menus
            set precio=nuevoPrecio
            where id=idMenu;

            if(ROW_COUNT()>0) THEN
                set mensaje="Precio Menu actualizado con exito";
            else
                set mensaje = "Error al Actualizar el menu";
            end if;

            select mensaje;

        end$$
    delimiter ;

    call ActualizarPrecioMenu(1,2000);
    ```


4. Enunciado: Crea un procedimiento almacenado llamado EliminarCliente que reciba como parámetro el ID del cliente y elimine el cliente junto con todos sus pedidos y los detalles de los pedidos.

```sql
delimiter $$
    create procedure EliminarCliente(in idCliente int)
    begin
        declare mensaje varchar(100);

        delete from DetallesPedidos as dtpd
        where dtpd.id_pedido in (select pd.id from Pedidos as pd where  pd.id_cliente=idCliente);

        delete from Pedidos as pd 
        where pd.id_cliente=idCliente;

        delete from Clientes as cli
        where cli.id = idCliente;

        if(ROW_COUNT() >0) THEN
            set mensaje = "Cliente Eliminado con exito";
        else 
            set mensaje = "Error al eliminar el cliente";
        end if;

        select mensaje;
    end;
delimiter;

call EliminarCliente(2);
``` 

5. Enunciado: Crea un procedimiento almacenado llamado TotalGastadoPorCliente que reciba como parámetro el ID del cliente y devuelva el total gastado por ese cliente en todos sus pedidos.

```sql
delimiter $
    create procedure TotalGastadoPorCliente(in idCliente int)
    begin
        select cli.nombre as Nombre,sum(pd.total) as "Total Gastado"
        from Clientes as cli 
        inner join Pedidos as pd on pd.id_cliente=cli.id
        where cli.id= idCliente
        group by cli.nombre;
        
    end;
delimiter ;
call TotalGastadoPorCliente(2);
```





