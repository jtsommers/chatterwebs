import os
from datetime import *
from google.appengine.ext import db
from google.appengine.ext import webapp
from google.appengine.ext.webapp import util
from google.appengine.ext.webapp import template

# Model Classes
class Group(db.Model):
	nickname = db.StringProperty()
	created = db.DateTimeProperty(auto_now_add=True)
	seatQTY = db.IntegerProperty()
	ticketnumber = db.IntegerProperty()
	
class Guest(db.Model):
	created = db.DateTimeProperty(auto_now_add=True)
	updated = db.DateTimeProperty(auto_now_add=True)
	group = db.ReferenceProperty(Group, collection_name='guests')
	nickname = db.StringProperty()
	ticketnumber = db.IntegerProperty()

# Controller Classes
# - decorator
class ajax_or_http_response(webapp.RequestHandler):
	def	get(self):
		# Load Template
		ext = template.split(".")[1]
		path = os.path.join(os.path.dirname(__file__), "templates/" + ext + "/" +template)
		self.response.out.write(template.render(path, template_values))
		
class ViewGroup(webapp.RequestHandler):
	def get(self, filename):
		# get template values
		group_id = self.request.get('group_id')
		group = Group.get(group_id)
		guests = group.guests.order('ticketnumber')
		for guest in guests:
			if(guest.updated < datetime.now() - timedelta(seconds=315)):
				guest.delete()
		guests.filter("ticketnumber >=", 0)
		seats = guests[0:8]
		queue = None
		if(guests.count() >= 8):
			queue = guests[8:20]
		template_values = {'group':group,
						   'seats':seats,
						   'queue':queue}
		
		# Load Template
		ext = filename.split(".")[1]
		path = os.path.join(os.path.dirname(__file__), "templates"+ os.sep + ext + os.sep +filename)
		self.response.out.write(template.render(path, template_values))
		
class ViewGuest(webapp.RequestHandler):
	def get(self, filename):
		# get template values
		guest_id = self.request.get('guest_id')
		guest = Guest.get(guest_id)
		template_values = {'guest': guest}
		
		# Load Template
		ext = filename.split(".")[1]
		path = os.path.join(os.path.dirname(__file__), "templates/" + ext + "/" +filename)
		self.response.out.write(template.render(path, template_values))	
			
class NewGroup(webapp.RequestHandler):
	def get(self, template=None, nickname=None):
		group = Group()
		if not(nickname):
			nickname = self.request.get("nickname")
		group.nickname = nickname
		group.seatQty = 8
		group.ticketnumber = 0
		group.put()
		self.redirect("/index.html")
		
	def post(self, template):
		nickname = self.request.get('nickname')
		self.get(template, nickname)
		
class NewGuest(webapp.RequestHandler):
	def get(self, filename):
		#create guest
		group_id = self.request.get('group_id')
		group = Group.get(group_id)
		guest = Guest()
		guest.nickname = self.request.get('nickname')
		guest.group = group
		
		#take a ticket
		guest.ticketnumber = group.ticketnumber
		group.ticketnumber = group.ticketnumber + 1
		group.put() #update group ticketnumber
		
		#add guest & update
		guest.put()
		
		ext = filename.split(".")[1]
		if(ext == 'xml'):
			self.redirect('/guest/'+filename+'?guest_id='+str(guest.key()))
		elif(ext == 'html'):	
			self.redirect('/group/'+filename+'?group_id='+group_id)
			
	
	def post(self, filename):
		self.get(filename)
		
class UpdateGuest(webapp.RequestHandler):
	def get(self, filename):
		guest_id = self.request.get("guest_id")
		group_id = self.request.get("group_id")
		guest = Guest.get(guest_id)
		guest.updated = datetime.now()
		guest.put()
		self.redirect("/group/"+filename+"?group_id="+group_id)
			
class DeleteGroup(webapp.RequestHandler):
	def get(self, template):
		group_id = self.request.get('group_id') 
		group = Group().get(group_id)
		group.delete()
		self.redirect("/index.html")
		
class DeleteGuest(webapp.RequestHandler):
	def get(self, template):
		guest_id = self.request.get('guest_id')
		group_id = self.request.get('group_id')
		guest = Guest().get(guest_id)
		guest.delete()
		self.redirect('/group/'+template+'?group_id='+group_id)
		
class Index(webapp.RequestHandler):
	def get(self, filename='index.html'):
		groups = Group.all()
		template_values = {'groups': groups}
		
		# Load Template
		ext = filename.split(".")[1]
		path = os.path.join(os.path.dirname(__file__), "templates/"+ext+"/"+filename)
		self.response.out.write(template.render(path, template_values))
		
class Redirect(webapp.RequestHandler):
	def get(self):
		self.redirect('/index.html')

def main():
	application = webapp.WSGIApplication([('/group/(.*?)', ViewGroup),
										  ('/guest/(.*?)', ViewGuest),
										  ('/new/group/(.*?)', NewGroup),
										  ('/new/guest/(.*?)', NewGuest),
										  ('/update/guest/(.*?)', UpdateGuest),
										  ('/delete/group/(.*?)',DeleteGroup),
										  ('/delete/guest/(.*?)',DeleteGuest),
										  ('/', Redirect),
										  ('/(.*?)', Index)
										  ],
       									  debug=True)
	util.run_wsgi_app(application)


if __name__ == '__main__':
  main()
