import os
from datetime import *
from google.appengine.ext import db
from google.appengine.ext import webapp
from google.appengine.ext.webapp import util
from google.appengine.ext.webapp import template

class Group(db.Model):
	nickname = db.StringProperty()
	created = db.DateTimeProperty(auto_now_add=True)
	members = db.IntegerProperty()
	
class Guest(db.Model):
	created = db.DateTimeProperty(auto_now_add=True)
	updated = db.DateTimeProperty(auto_now_add=True)
	group = db.ReferenceProperty(Group, collection_name='guests')
	nickname = db.StringProperty()
	
class MainHandler(webapp.RequestHandler):
	def get(self,group_id):
		template_values = {'group': group}
		path = os.path.join(os.path.dirname(__file__), 'session.html')
		self.response.out.write(template.render(path, template_values))

class Create(webapp.RequestHandler):
	def post(self, key):
		if(key == 'guest'):
			guest = Guest()
			guest.group = Group.get(self.request.get("groupid"))
			guest.nickname = self.request.get("nickname")
			guest.put()
			
			group = Group.get(self.request.get("groupid"))
			if not(group.members):
				group.members = 1
			else:
				group.members = group.members + 1
			group.put()
			self.redirect("/view/view.html?groupid=" + str(group.key()))
		if(key == 'group'):
			group = Group()
			group.nickname = self.request.get("nickname")
			group.members = 0
			group.put()
			self.redirect("/")	
		
class Update(webapp.RequestHandler):
	def get(self):
		id = self.request.get('guestid')
		guest = Guest.get(id)
		guest.updated = datetime.now()
		guest.put()
		self.redirect('/view/view.html?groupid='+self.request.get('groupid'))
			
class View(webapp.RequestHandler):
	def get(self, ext):
		key = self.request.get('groupid')
		group = Group.get(key)
		now = datetime.now()
		later = datetime.now() + timedelta(seconds=15)
		test = now > later
		guests = group.guests.filter("updated >", datetime.now() - timedelta(seconds=15)).order("-updated")[0:7]
		
		
		template_values = {'group': group,
						   'guests':guests,
						   'now':now,
						   'later':later}
		path = os.path.join(os.path.dirname(__file__), ext)
		self.response.out.write(template.render(path, template_values))

class Index(webapp.RequestHandler):
	def get(self):
		groups = Group.all()
		template_values = {'groups': groups}
		path = os.path.join(os.path.dirname(__file__), 'index.html')
		self.response.out.write(template.render(path, template_values))

def main():
	application = webapp.WSGIApplication([('/', Index),
										  ('/view/(.*?)', View),
										  ('/create/(.*?)/', Create),
										  ('/update/', Update),
  										  ('/(.*?)/', MainHandler)],
                                       debug=True)
	util.run_wsgi_app(application)


if __name__ == '__main__':
  main()
