# Database
This is a project about creating a database for an online staff evaluation system.

## About
This project was part of the Databases course in the third year of CEID, University of Patras. It was created in collaboration with [@eleftheriavs](https://github.com/eleftheriavs).
It was written using _MySQL_.

The database includes the creation of tables, procedures and triggers necessary for the assignment's requirements, as well as the insertion of needed data.

## Content
Included is a relational diagramm, showing all the tables, the fields and their properties in each table and the relations of each table with each other.
After that, the entire database and it's components are included in the `.sql` file.

### Setup and tools
A local server was hosted using _MySQL Workbench_, with the latter also being used to help create the project in _MySQL_.

### Details
The assignment had two phases: a **Preparatory Phase** and an **Added Requirements Phase**.

In the **Preparation Phase**, the starting database was created from a starting relational diagramm: <img width="1050" height="635" alt="image" src="https://github.com/user-attachments/assets/7bfaa82b-7e41-4c5f-8910-ab65fc796b88" />
After that, a number of inserts were created for each table, showing all possible relations of each table.

In the **Added Requirements Phase**, more fields and tables were created, as well as procudures and triggers to fulfill the extra requirements. The last ones included: mechanisms to insert and manage the promotion applications, a mechanism to evaluate and export results for the promοtion applications, creating an application history and creating a database admin. Each requirements had different subrequirements into it. Lastly, indexes were also used in the application history table to speed up searching significantly. Thus, we get the final relational graph:
<img width="912" height="543" alt="image" src="https://github.com/user-attachments/assets/756e5c64-cfb4-4072-99fc-518c1c690f2b" />


