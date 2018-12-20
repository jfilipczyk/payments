package server

import (
	"fmt"
	"net/http"

	log "github.com/sirupsen/logrus"

	"github.com/gin-gonic/gin"
	"github.com/jfilipczyk/payments/config"
	"github.com/jfilipczyk/payments/model"
)

type Server struct {
	port   int
	engine *gin.Engine
	ctrl   *controller
}

func NewServer(repo model.Repository, cfg *config.Config) *Server {
	ctrl := newController(repo)
	engine := gin.Default()
	engine.Use(errorHandler())
	v1 := engine.Group("/v1")
	{
		v1.POST("/payments", ctrl.Create)
		v1.GET("/payments/:id", ctrl.Get)
		v1.GET("/payments", ctrl.GetList)
		v1.PUT("/payments/:id", ctrl.Upsert)
		v1.DELETE("/payments/:id", ctrl.Delete)
	}
	return &Server{cfg.Port, engine, ctrl}
}

func (s *Server) ServeHTTP(w http.ResponseWriter, req *http.Request) {
	s.engine.ServeHTTP(w, req)
}

func (s *Server) Run() {
	s.engine.Run(fmt.Sprintf(":%d", s.port))
}

func errorHandler() gin.HandlerFunc {
	return func(c *gin.Context) {
		c.Next()
		for _, err := range c.Errors {
			log.Error(err)
		}
	}
}
