from functools import wraps
from pymongo import CursorType, MongoClient
from bson.objectid import ObjectId


class Database:
    """
    This class is stands for CRUD operation in MongoDB databases.

    methods:
        _get_collection()
        insert()
        get()
        update()

    Context Manager:
        __enter__()
        __exit__()
    """

    def __init__(self, host: str, port: int, db_name: str, collection_name: str) -> None:
        """
        Here we connect to the MongoDB via MongoClient and get the desired database.

        params:
            host -> Address of the mongodb
            port -> Port of the mongodb
            db_name -> The name of the desired database
        """
        self.client = MongoClient(host=host, port=port)
        self.db = self.client[db_name]
        self.collection = collection_name

    @property
    def collection(self):
        return self._collection

    @collection.setter
    def collection(self, value) -> None:
        """"""
        collections = self.db.list_collection_names()
        if not value in collections:
            raise ValueError("There is not desired collection!")
        self._collection = self.db[value]

    def _change_collection(func: object) -> None:
        """
        This is a decorator function which other functions add this
        function as a decorator.
        For each operation if the collection have to be changed
        here we change the self.collection.
        """

        @wraps(func)
        def wrapper(self, *args, **kwargs):
            """
            There we check if new collection_name exists, replace it with
            previous collection_name.
            """
            if kwargs.get('collection_name'):
                self.collection = kwargs['collection_name']
                return func(self, *args, **kwargs)
            return func(self, *args, **kwargs)
        return wrapper

    def __enter__(self) -> None:
        """
        Implementing this magic method to convert this class to
        context manager.
        We return self to use instantiating in the with statement like:
        with class() as c
        """
        return self

    def __exit__(self, exc_type, exc_value, exc_traceback) -> None:
        """ 
        Implementing this magic method to convert this class to
        context manager.
        After this class in a with statement wants to be closed,
        here the connection with the database will be terminated.
        """
        self.client.close()

    @_change_collection
    def get_record(self,
                   query: dict = {},
                   projection: dict = {},
                   find_one=True,
                   collection_name: str = None,
                   ) -> dict or CursorType:
        """
        This method gets a criteria as a dict and search in database for
        data.
        args:
            query -> dict : The desired
            projection -> dict : The part of a data which needs to extract
        """
        if find_one:
            return self.collection.find_one(query, projection)
        return self.collection.find(query, projection)

    @_change_collection
    def insert_record(self,
                      data: dict or list,
                      collection_name: str = None,
                      ) -> ObjectId or list:
        """
        This method gets a dictionary or list and based on its type
        insert it into database, If instance is dict then we use insert_one
        otherwise insert_many.
        args:
            data -> dict or list
            collection_name -> str
        """

        if isinstance(data, dict):
            return self.collection.insert_one(data).inserted_id
        return self.collection.insert_many(data).inserted_ids

    @_change_collection
    def update_record(self,
                      query: dict,
                      updated_data: dict,
                      update_one: bool = True,
                      collection_name: str = None,
                      ) -> int:
        """
        This method update a document or part of it. First by query 
        database find the desire document and with updated_data, update
        the desired data.

        args:
            query -> dict
            updated_data -> dict
            collection_name -> str
            update_one -> bool
        """
        print(collection_name)
        if update_one:
            return self.collection.update_one(query, updated_data).matched_count
        return self.collection.update_many(query, updated_data).acknowledged

    @_change_collection
    def replace_record(self,
                       query: dict,
                       replaced_data: dict,
                       collection_name: str = None,
                       ) -> None:
        """
        This method gets a query and with that replace that document 
        with new one.

        args:
            query -> dict
            replaced_data: -> dict
        """
        return self.collection.find_one_and_replace(query, replaced_data)

    @_change_collection
    def delete_record(self,
                      query: dict,
                      delete_one: bool = True,
                      collection_name: str = None,
                      ) -> None:
        """
        This method is stands for remove operation in CRUD.
        First it based on the deleting type(one or many), it will remove
        the document or nested document or field.

        args:
            query -> dict
            delete_one -> bool
        """
        if delete_one:
            return self.collection.delete_one(query)
        self.collection.delete_many(query)

    @_change_collection
    def aggregate(self, piplines: list, collection_name: str = None) -> CursorType:
        """
        This method is execute aggregation framework pipelines.
        """

        return self.collection.aggregate(piplines)
