
const productdb = (dbname, table) => {
    //Create db

    const db = new Dexie(dbname);
    db.version(1).stores(table);
    db.open();

    /*
    const db = new Dexie("moduledb");
    db.version(1).stores({
        friends: `name, age`
    })*/

    return db;
}

//insert function
const bulkcreate = (dbtable, data) => {
    let flag = empty(data);
    if (flag) {
        dbtable.bulkAdd([data]);
        console.log("data inserted successfully");
    } else {
        console.log("Data is either not provided or incomplete. Please provide data...,")
    }
    return flag
}

//check textbox validation
const empty = object => {
    let flag = false;

    for (const value in object) {
        if (object[value] != "" && object.hasOwnProperty(value)) {
            flag = true;
        } else {
            flag = false;
        }
    }
    return flag;
}

const getData = (dbtable, fn) => {
    let index = 0;
    let obj = {};

    dbtable.count((count) => {
        if (count) {
            dbtable.each(table => {
                //console.log(table);
                // console.log(SortObj(table));
                obj = SortObj(table);
                fn(obj, index++)
            })
        } else (fn(0));
    })
}

//Sort objects
const SortObj = sortobj => {
    let obj = {};
    obj = {
        id: sortobj.id,
        name: sortobj.name,
        seller: sortobj.seller,
        price: sortobj.price
    }
    return obj;
}


export default productdb;
export {
    bulkcreate,
    getData
};