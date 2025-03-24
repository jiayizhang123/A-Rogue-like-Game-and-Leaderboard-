#import library
import pandas as pd
import datetime as dt
import json
import sys
import os

from flask import Flask,render_template,url_for,request,redirect,jsonify
from flask_sqlalchemy import SQLAlchemy
from flask_login import current_user, LoginManager, login_user, logout_user, UserMixin
from flask_admin import Admin, AdminIndexView
from flask_admin.contrib.sqla import ModelView
#import file
from forms import LoginForm, RegisterForm
from config import Config

# PARAMETER

## Leaderboard parameter
limit_lb = 100 # Number of user showed at leaderboard table

game = "Dungeon"

# Dynamically obtain the base path
def get_base_dir():
    if getattr(sys, 'frozen', False):
        # The directory where the packaged environment :.exe located
        base_dir = os.path.dirname(sys.executable)
    else:
        # Development Environment: The directory where the script is located
        base_dir = os.path.dirname(os.path.abspath(__file__))
    
    #print(f"[DEBUG] database base dir: {base_dir}")  
    return base_dir

## FLASK configuration
app = Flask(__name__)
app.config['MAX_CONTENT_LENGTH'] = 2 * 1024 * 1024 # 2 Megabytes
app.config['SECRET_KEY'] = 'Roguelike'
app.config.from_object(Config)

# set base dir for database
db_path = os.path.join(get_base_dir(), "app.db")
#print(f"[DEBUG] The full path of the database: {db_path}")  
app.config['SQLALCHEMY_DATABASE_URI'] = f'sqlite:///{db_path}'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
## Database configuration
db = SQLAlchemy(app)
db.app = app

login = LoginManager(app)

# Database Model
@login.user_loader
def load_user(id):
    return User.query.get(int(id))
#user table
class User(UserMixin, db.Model):
    __tablename__ = "user"
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(64), index=True, unique=True)
    password = db.Column(db.String(64)) 

    def __repr__(self):
        return self.username

    def check_password(self, password): 
        return self.password == password
#submission table
class Submission(db.Model):
    __tablename__ = "submission"
    id = db.Column(db.Integer, primary_key=True)
    timestamp = db.Column(db.DateTime, index=True, default=dt.datetime.now)
    submission_type = db.Column(db.String(64))
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'))
    user = db.relationship('User')
    score = db.Column(db.Float)

    def __repr__(self):
        return f'<User ID {self.user_id} score {self.score}>'
#create database if it doesnot exist
with app.app_context():
    db.create_all()
    admin1 = User.query.filter_by(username='admin').first()
    if admin1 is None: #add admin account
        u = User(username='admin', password = 'admin')
        db.session.add(u)
        db.session.commit()

# Admin management
class MyAdminIndexView(AdminIndexView):
    def is_accessible(self):
        if current_user.is_authenticated:
            return current_user.username == 'admin'
        else:
            False

    def inaccessible_callback(self, name, **kwargs):
        return redirect(url_for('home_page'))

class UserView(ModelView):
    column_list = (User.id, 'username','password')
    can_create = False
    def is_accessible(self):
        if current_user.is_authenticated:
            return current_user.username == 'admin'
        else:
            False
    def inaccessible_callback(self, name, **kwargs):
        return redirect(url_for('home_page'))

class SubmissionView(ModelView):
    column_list = (Submission.id, 'submission_type', 'user_id', 'user',  'timestamp', 'score')
    can_create = False
    def is_accessible(self):
        if current_user.is_authenticated:
            return current_user.username == 'admin'
        else:
            False

    def inaccessible_callback(self, name, **kwargs):
        return redirect(url_for('home_page'))

admin = Admin(app, index_view=MyAdminIndexView())
admin.add_view(UserView(User, db.session))
admin.add_view(SubmissionView(Submission, db.session))



# get leader Board data
def get_leaderboard(limit, submission_type = game):
    
    query = f"""
            SELECT
            user.username, 
            submission.score,
            submission.timestamp
            FROM submission 
            LEFT JOIN user 
            ON user.id = submission.user_id
            WHERE submission_type = '{submission_type}'
            ORDER BY submission.score DESC
            LIMIT {limit}
            """
    with app.app_context():
        df = pd.read_sql(query, db.get_engine())
    return df

# Route
@app.route('/register', methods=['GET', 'POST'])
def register_page():
    registration_status = request.args.get("registration_status", "")
    reg_form = RegisterForm()

    if request.method == 'POST': 
        ### REGISTRATION
        if reg_form.validate_on_submit():
            user = User.query.filter_by(username=reg_form.username.data).first()
            print(user)
            if user is None: # only when user is not registered then proceed
                
                u = User(username=reg_form.username.data, password = reg_form.password.data)
                db.session.add(u)
                db.session.commit()
                
                registration_status = f"Welcome {reg_form.username.data}, Please Login at HOME page"
                return redirect(url_for('register_page', registration_status = registration_status))
            else:
                registration_status = "USER NAME ALREADY USED"
                return redirect(url_for('register_page', registration_status = registration_status))
        else:
            registration_status = "ERROR VALIDATION"
            
            return redirect(url_for('register_page', registration_status = registration_status))
        
    if request.method == 'GET':
        return render_template('register.html', reg_form = reg_form, registration_status = registration_status)

@app.route('/logout')
def logout():
    logout_user()
    print("log out success")
    return redirect(url_for('home_page'))

@app.route('/', methods=['GET', 'POST'])
def home_page():
        
    login_form = LoginForm()
    login_status = request.args.get("login_status", "")
    submission_status = request.args.get("submission_status", "")

    leaderboard = get_leaderboard(limit = limit_lb, submission_type=game)
    
    if request.method == 'POST': 
        #print(request.args)
        #print(request.form)
        #print(request.form['username'])
       
        ### LOGIN 
        
        if login_form.validate_on_submit():
            print(f'Login requested for user {login_form.username.data}, remember_me={login_form.remember_me.data}')
            user = User.query.filter_by(username=login_form.username.data).first()
            if user is None: # USER is not registered
                login_status = "User is not registered / Password does not match"
                return redirect(url_for('home_page', login_status = login_status))
            elif user.check_password(login_form.password.data): # Password True
                print('True pass')
                login_status = ""
                login_user(user, remember=login_form.remember_me.data)
                return redirect(url_for('home_page', login_status = login_status))
            else: #WRONG PASSWORD
                print('WRONG PASS')
                login_status = "User is not registered / Password does not match"
                return redirect(url_for('home_page', login_status = login_status))
            login_status = ""
            login_user(user, remember=login_form.remember_me.data)
            return redirect(url_for('home_page', login_status = login_status))
        #request with submission is from web or game application
        if "submission_type" in request.form:
            if request.form.get('submission_type') == game:
                
                user_name = request.form.get('username')
                pass_word = request.form.get('pass')
                with app.app_context():
                    df = pd.read_sql("SELECT id from user WHERE username='"+user_name+"' AND password='"+pass_word+"'", db.get_engine())
                
                #print(df)
                if not df.empty:
                    #print(df.get('id')[0])
                    #return leaderboard's data            
                    if request.form.get('APP') == 'gameleaderboard':
                        df1 = pd.read_sql("SELECT user.username, submission.score, submission.timestamp FROM submission LEFT JOIN user \
                        ON user.id = submission.user_id ORDER BY submission.score DESC", db.get_engine())
                        json_data = df1.to_json(orient='records', indent=4)
                        
                        return json.dumps(json_data)
                        
                    else: #add data into leaderboard
                        s = Submission(user_id=int(df.get('id')[0]) , score=request.form['score'], submission_type = request.form.get('submission_type'))
                        db.session.add(s)
                        db.session.commit()
                    if request.form.get('APP') == 'web': #refresh status if request is from web
                        submission_status =  f"SUBMISSION SUCCESS " 
                elif request.form.get('APP') == 'web': #username/password is not correct
                    submission_status =  f"SUBMISSION FAILED " 
                else: #username/password is not correct
                    return jsonify({"error": "Empty 'query' parameter"}), 400
                

        
    return render_template('index.html', 
                        leaderboard = leaderboard,
                        login_form=login_form, 
                        login_status=login_status,
                        submission_status=submission_status,
                        game = game
    )

if __name__ == '__main__':
    #app.debug = True
    app.run(host = '0.0.0.0',port=5005)