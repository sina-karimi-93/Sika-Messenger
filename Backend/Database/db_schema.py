from bson.objectid import ObjectId
from bson import json_util
from datetime import datetime
import bcrypt


def encode_password(password: str) -> str:
    """
    This function hash passwords and return them as string to 
    store them in database.
    """

    hashed_password = bcrypt.hashpw(password.encode(), bcrypt.gensalt())
    return hashed_password.decode()


def check_password(password: str, encoded_password: str) -> bool:
    """
    This method check whether a password is match to existing or not.

    args:
        password -> input password from client
        encoded_password -> existing password in database
    """

    is_match = bcrypt.checkpw(password.encode(), encoded_password.encode())
    return is_match


sina = '62865df926772d1facf9fadd'
ali = '62865df926772d1facf9fade'
mohammad = '62865df926772d1facf9fadf'
hadi = '62865df926772d1facf9fae0'
zeinab = '62865df926772d1facf9fae1'


users = [
    {
        "_id": ObjectId(sina),
        "name": "Sina Karimi",
        "email": "sina@gmail.com",
        "password": encode_password("1111"),
        "phone_number": +989150000000,
        "create_date": datetime.now(),
        "profile_pictures": [],
        "chats": [
            ObjectId("6286627326772d1facf9fae9"),
            ObjectId("6286627326772d1facf9faea"),
            ObjectId("6286627326772d1facf9faeb"),
            ObjectId("6286627326772d1facf9faec"),
        ],
        "groups":[],
        "channels":[]
    },
    {
        "_id": ObjectId(ali),
        "name": "Ali Karimi",
        "email": "ali@gmail.com",
        "password": encode_password("1111"),
        "phone_number": +989160000000,
        "create_date": datetime.now(),
        "profile_pictures": [],
        "chats": [
            ObjectId("6286627326772d1facf9fae9")
        ],
        "groups":[],
        "channels":[]
    },
    {
        "_id": ObjectId(mohammad),
        "name": "Mohammad Karimi",
        "email": "mohammad@gmail.com",
        "password": encode_password("1111"),
        "phone_number": +989170000000,
        "create_date": datetime.now(),
        "profile_pictures": [],
        "chats": [
            ObjectId("6286627326772d1facf9faea")
        ],
        "groups":[],
        "channels":[]
    },
    {
        "_id": ObjectId(hadi),
        "name": "Hadi Karimi",
        "email": "hadi@gmail.com",
        "password": encode_password("1111"),
        "phone_number": +989150000000,
        "create_date": datetime.now(),
        "profile_pictures": [],
        "chats": [
            ObjectId("6286627326772d1facf9faeb")
        ],
        "groups":[],
        "channels":[]
    },
    {
        "_id": ObjectId(zeinab),
        "name": "Zeinab Ebrahimi",
        "email": "zeinab@gmail.com",
        "password": encode_password("1111"),
        "phone_number": +989180000000,
        "create_date": datetime.now(),
        "profile_pictures": [],
        "chats": [
            ObjectId("6286627326772d1facf9faec")
        ],
        "groups":[],
        "channels":[]
    }, {
        "name": "Reza Hejazi",
        "email": "reza@gmail.com",
        "password": encode_password("1111"),
        "phone_number": +989190000000,
        "create_date": datetime.now(),
        "profile_pictures": [],
        "chats": [],
        "groups":[],
        "channels":[]
    },
    {
        "name": "Mohammad Tavakoli",
        "email": "mohammad@gmail.com",
        "password": encode_password("1111"),
        "phone_number": +989200000000,
        "create_date": datetime.now(),
        "profile_pictures": [],
        "chats": [],
        "groups":[],
        "channels":[]
    },
    {
        "name": "Sed Morteza Hossein",
        "email": "morteza@gmail.com",
        "password": encode_password("1111"),
        "phone_number": +989210000000,
        "create_date": datetime.now(),
        "profile_pictures": [],
        "chats": [],
        "groups":[],
        "channels":[]
    },
    {
        "name": "Sina Karimi",
        "email": "sina@gmail.com",
        "password": encode_password("1111"),
        "phone_number": +989220000000,
        "create_date": datetime.now(),
        "profile_pictures": [],
        "chats": [],
        "groups":[],
        "channels":[]
    },
    {
        "name": "Farhad Karimi",
        "email": "farhad@gmail.com",
        "password": encode_password("1111"),
        "phone_number": +989230000000,
        "create_date": datetime.now(),
        "profile_pictures": [],
        "chats": [],
        "groups":[],
        "channels":[]
    }
]

chats = [
    {
        "owners": [ObjectId(sina), ObjectId(ali)],
        "create_date": datetime.now(),
        "messages": [
            {
                "_id": ObjectId(),
                "message": "Hello",
                "owner": ObjectId(sina),
                "create_date": datetime.now(),
                "update_date": None,
            },
            {
                "_id": ObjectId(),
                "message": "Chtori?",
                "owner": ObjectId(sina),
                "create_date": datetime.now(),
                "update_date": None,
            },
            {
                "_id": ObjectId(),
                "message": "Salam",
                "owner": ObjectId(ali),
                "create_date": datetime.now(),
                "update_date": None,
            },
            {
                "_id": ObjectId(),
                "message": "Merc Khubam",
                "owner": ObjectId(ali),
                "create_date": datetime.now(),
                "update_date": None,
            },
            {
                "_id": ObjectId(),
                "message": "To chtori?",
                "owner": ObjectId(ali),
                "create_date": datetime.now(),
                "update_date": None,
            },
            {
                "_id": ObjectId(),
                "message": "Ghorbunet Manam khubam",
                "owner": ObjectId(sina),
                "create_date": datetime.now(),
                "update_date": None,
            },
        ]
    },
    {
        "owners": [ObjectId(sina), ObjectId(mohammad)],
        "create_date": datetime.now(),
        "messages": [
            {
                "_id": ObjectId(),
                "message": "Salam baba",
                "owner": ObjectId(sina),
                "create_date": datetime.now(),
                "update_date": None,
            },
            {
                "_id": ObjectId(),
                "message": "Chtorin?",
                "owner": ObjectId(sina),
                "create_date": datetime.now(),
                "update_date": None,
            },
            {
                "_id": ObjectId(),
                "message": "Salam pesaram",
                "owner": ObjectId(mohammad),
                "create_date": datetime.now(),
                "update_date": None,
            },
            {
                "_id": ObjectId(),
                "message": "Mamnun Khubam",
                "owner": ObjectId(mohammad),
                "create_date": datetime.now(),
                "update_date": None,
            },
            {
                "_id": ObjectId(),
                "message": "Shoma chtori?",
                "owner": ObjectId(mohammad),
                "create_date": datetime.now(),
                "update_date": None,
            },
            {
                "_id": ObjectId(),
                "message": "Ghorbunet Manam khubam",
                "owner": ObjectId(sina),
                "create_date": datetime.now(),
                "update_date": None,
            },
            {
                "_id": ObjectId(),
                "message": "Mashin Key miari?",
                "owner": ObjectId(mohammad),
                "create_date": datetime.now(),
                "update_date": None,
            },
            {
                "_id": ObjectId(),
                "message": "Bezudi",
                "owner": ObjectId(sina),
                "create_date": datetime.now(),
                "update_date": None,
            },
        ]
    },
    {
        "owners": [ObjectId(sina), ObjectId(hadi)],
        "create_date": datetime.now(),
        "messages": [
            {
                "_id": ObjectId(),
                "message": "Salam sina",
                "owner": ObjectId(hadi),
                "create_date": datetime.now(),
                "update_date": None,
            },
            {
                "_id": ObjectId(),
                "message": "chekhabar?",
                "owner": ObjectId(hadi),
                "create_date": datetime.now(),
                "update_date": None,
            },
            {
                "_id": ObjectId(),
                "message": "Salam Hadi",
                "owner": ObjectId(sina),
                "create_date": datetime.now(),
                "update_date": None,
            },
            {
                "_id": ObjectId(),
                "message": "Hichi salamaty",
                "owner": ObjectId(sina),
                "create_date": datetime.now(),
                "update_date": None,
            },
            {
                "_id": ObjectId(),
                "message": "Key berim birun?",
                "owner": ObjectId(hadi),
                "create_date": datetime.now(),
                "update_date": None,
            },
            {
                "_id": ObjectId(),
                "message": "Shab berim",
                "owner": ObjectId(sina),
                "create_date": datetime.now(),
                "update_date": None,
            },
            {
                "_id": ObjectId(),
                "message": "hamahange",
                "owner": ObjectId(hadi),
                "create_date": datetime.now(),
                "update_date": None,
            },
        ]
    },
    {
        "owners": [ObjectId(sina), ObjectId(zeinab)],
        "create_date": datetime.now(),
        "messages": [
            {
                "_id": ObjectId(),
                "message": "Hi Baby",
                "owner": ObjectId(sina),
                "create_date": datetime.now(),
                "update_date": None,
            },
            {
                "_id": ObjectId(),
                "message": "Chtori Azizam?",
                "owner": ObjectId(sina),
                "create_date": datetime.now(),
                "update_date": None,
            },
            {
                "_id": ObjectId(),
                "message": "Salam Dina",
                "owner": ObjectId(zeinab),
                "create_date": datetime.now(),
                "update_date": None,
            },
            {
                "_id": ObjectId(),
                "message": "Khubam azizam to Chtori? Emshab Berim Birun?",
                "owner": ObjectId(zeinab),
                "create_date": datetime.now(),
                "update_date": None,
            },
            {
                "_id": ObjectId(),
                "message": "Are berim ye shami bezanim",
                "owner": ObjectId(sina),
                "create_date": datetime.now(),
                "update_date": None,
            },
            {
                "_id": ObjectId(),
                "message": "Jiaaan <3 <3",
                "owner": ObjectId(zeinab),
                "create_date": datetime.now(),
                "update_date": None,
            },
        ]
    },

]


# groups = [
#     {
#         "_id": ObjectId("g1"),
#         "group_name": "Programmers",
#         "create_date": datetime.now(),
#         "owner": ObjectId("u1"),
#         "admins": [
#             ObjectId("u1"),
#             ObjectId("u2"),
#             ObjectId("u3"),
#         ],
#         "messages": [
#             {
#                 "_id": ObjectId("m5"),
#                 "message": "Hi everyone!",
#                 "owner": ObjectId('u1'),
#                 "create_date": datetime.now(),
#                 "update_date": datetime.now()
#             },
#         ],
#         "members": [
#             ObjectId('u1'),
#             ObjectId('u2'),
#             ObjectId('u3'),
#             ObjectId('u4'),
#             ObjectId('u5'),
#         ]
#     }
# ]


# channels = [
#     {
#         "_id": ObjectId("ch1"),
#         "channel_name": "Programming Lessons",
#         "create_date": datetime.now(),
#         "owner": ObjectId('u1'),
#         "admins": [
#             ObjectId('u1'),
#             ObjectId('u2'),
#             ObjectId('u3'),
#             ObjectId('u4'),
#         ],
#         "messages":[
#             {
#                 "_id": ObjectId("m10"),
#                 "owner": ObjectId("u1"),
#                 "create_date": datetime.now(),
#                 "update_date": datetime.now(),
#                 "message": "Follow the pep8",
#             }
#         ],
#         "members": [
#             ObjectId("u1"),
#             ObjectId("u2"),
#             ObjectId("u3"),
#             ObjectId("u4"),
#             ObjectId("u5"),
#         ]
#     }
# ]


with open("./Data/users.json", 'w') as f:
    f.write(json_util.dumps(users, indent=4))
