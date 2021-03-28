# Lambdabuster
Proyecto elaborado para la materia CI-3661 - Laboratorio de Lenguajes de 
Progrmación I en el trimestre Enero - Abril 2021. 

El proyecto consiste en la creación de un sistema de alquiler y venta de películas
llamado *Lambdabuster*, desarrollado en su totalidad en el lenguaje de programación
*Ruby*. La finalidad es demostrar los conocimientos adquiridos sobre el funcionamiento
de lenguajes puramente orientados a objetos.

## ¿Cómo correr el programa?

Para ejecutar *Lambdabuster* solo es necesario tener Ruby instalado, y ejecutar
el siguiente comado:

`ruby lambdabuster.rb`

Esto iniciará el cliente en el cuál se presentan una serie de opciones para
el alquiler, compra y consulta de películas cargadas en la base da datos.

La base de datos es poblada al inicio del programa cliente, en el cuál se le 
pregunta al usuario el nombre de un archivo `.json` (debe incluir la extensión)
con el formato descrito en el archivo `key.json`.

## Detalles Relevantes de la Implementación

### Clase Cliente
La clase `Cliente` se encarga de procesar todas las acciones que realiza el usuario. Al inicializarlas, se crea una instancia de `User` para almacenar las transacciones realizadas, además de un diccionario `compare_options` que mapea los números del 1 al 5 como strings a los símbolos `<`, `<=`, `==`, `>=` y `>` respectivamente. La función de este atributo será explicado mas adelante. 

El método `read_json` se encarga precisamente de leer y almacenar los datos que se encuentran en un archivo JSON que se le pase como argumento, siguiendo el formato dado en el enunciado. Al leer los directores y actores, verifica que no aparezcan dos personas distintas con el mismo nombre y el mismo rol. Para almacenar las categorías decidimos usar una instancia de `Set`, los que nos ahorra tener que hacer las verificación de repetición.

Debido a que el programa tiene varios sub-menús, decidimos crear un metodo `menu` generalizado, el cual toma un conjunto de opciones válidas y una función que imprime un menú, y se mantiene en un bucle hasta que el usuario seleccione alguna opción válida.

También nos dimos cuenta que las acciones de compra y renta de películas tienen una estructura casi idéntica, por lo que creamos un sólo método `buy` para ambas, el cual toma de argumento el tipo de transacción, la lista de transacciones de ese mismo tipo que el usuario ha realizado, y un string con el verbo que representa dicha acción.

Para la consulta de usuario se creó el método `my_user`, del cual lo único importante a destacar fue el tener que incluir el método `include` a la clase `SearchList` para verificar si una película estaba incluida en la lista de películas alquiladas o compradas por el usuario.

El metodo que se encarga de realizar un solo filtro es `filter`, el cual toma un `SearchList` y retorna otro con el filtro correspondiente. Existen 3 tipos de filtros en este proyecto:

 * Filtro por texto. Consiste en buscar aquellas películas que incluyan algún atributo con el texto indicado, ya sea por coincidencia parcial o total. Para realizar esto, simplemente realizamos un `scan` sobre el atributo correspondiente, comparandolo con el string indicado usando `==` para coincidencia total y `include?` para coincidencia parcial. Para las coincidencias de los actores o directores, usamos el metodo `any?` para verificar que alguno cumple la condicion.

 * Filtro por comparación de números. Consiste en verificar si algún atributo cumple una relación de orden respecto a la cantidad indicada. Aqui es donde entra en juego el atributo `compare_options`, pues solo necesitamos pasarle la opción correspondiente y nos da la operación de comparación, así que no necesitamos realizar un `if elsif else` de 5 guardias.

 * Filtro por contención. El único filtro que aplica tipo este es el de las categorías, y consiste en verificar que las categorías de una película contiene todas las categorías indicadas. Para realizar esto verificamos que para toda (`all?`) categoria en la lista indicada, está incluida (`include?`) en la lista de categorías de la película.

## Integrantes
- Amin Arriaga (16-10072)
- Manuel Faria (15-10463)