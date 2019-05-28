package server

import (
	"errors"
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/jfilipczyk/payments/model"
	uuid "github.com/satori/go.uuid"
)

var errInvalidIDFormat = errors.New("invalid id format, uuid required")

type controller struct {
	repo model.Repository
}

func newController(repo model.Repository) *controller {
	return &controller{repo}
}

func (ctrl *controller) Upsert(c *gin.Context) {
	var payment model.Payment
	if err := c.ShouldBindJSON(&payment); err != nil {
		badRequest(c, err)
		return
	}
	id, err := getIDFromParams(c)
	if err != nil {
		badRequest(c, err)
		return
	}
	payment.ID = id
	err = ctrl.repo.Upsert(&payment)
	if err != nil {
		internalServerError(c, err)
		return
	}
	dto := newPaymentRespDTO(&payment)
	ok(c, dto)
}

func (ctrl *controller) Get(c *gin.Context) {
	id, err := getIDFromParams(c)
	if err != nil {
		badRequest(c, err)
		return
	}
	payment, err := ctrl.repo.GetByID(id)
	if err == model.ErrNotFound {
		notFound(c)
		return
	}
	if err != nil {
		internalServerError(c, err)
		return
	}
	dto := newPaymentRespDTO(payment)
	ok(c, dto)
}

func (ctrl *controller) GetList(c *gin.Context) {
	list, err := ctrl.repo.GetList()
	if err != nil {
		internalServerError(c, err)
		return
	}
	dto := newPaymenListRespDTO(list)
	ok(c, dto)
}

func (ctrl *controller) Delete(c *gin.Context) {
	id, err := getIDFromParams(c)
	if err != nil {
		badRequest(c, err)
		return
	}
	err = ctrl.repo.Delete(id)
	if err != nil {
		internalServerError(c, err)
		return
	}
	noContent(c)
}

func getIDFromParams(c *gin.Context) (string, error) {
	id := c.Param("id")
	if _, err := uuid.FromString(id); err != nil {
		return "", errInvalidIDFormat
	}
	return id, nil
}

func badRequest(c *gin.Context, err error) {
	c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
	c.Error(err)
}

func notFound(c *gin.Context) {
	c.Status(http.StatusNotFound)
}

func internalServerError(c *gin.Context, err error) {
	c.JSON(http.StatusInternalServerError, gin.H{"error": "Something went wrong"})
	c.Error(err)
}

func created(c *gin.Context, selfHref string) {
	c.Header("Location", selfHref)
	c.Status(http.StatusCreated)
}

func ok(c *gin.Context, data interface{}) {
	c.JSON(http.StatusOK, data)
}

func noContent(c *gin.Context) {
	c.Status(http.StatusNoContent)
}
