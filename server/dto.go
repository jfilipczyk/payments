package server

import "github.com/jfilipczyk/payments/model"

const (
	self     = "self"
	basePath = "/v1/payments"
)

type paymentRespDTO struct {
	*model.Payment
	Links []*link `json:"links"`
}

type paymentListRespDTO struct {
	Data  []*paymentRespDTO `json:"data"`
	Links []*link           `json:"links"`
}

type link struct {
	Rel  string `json:"rel"`
	Href string `json:"href"`
}

func newPaymentRespDTO(p *model.Payment) *paymentRespDTO {
	links := []*link{
		newLinkSelf(p),
	}
	return &paymentRespDTO{p, links}
}

func newPaymenListRespDTO(list []*model.Payment) *paymentListRespDTO {
	data := make([]*paymentRespDTO, len(list))
	for i := 0; i < len(list); i++ {
		data[i] = newPaymentRespDTO(list[i])
	}
	links := []*link{
		&link{
			Rel:  self,
			Href: basePath,
		},
	}
	return &paymentListRespDTO{data, links}
}

func newLinkSelf(p *model.Payment) *link {
	return &link{
		Rel:  self,
		Href: basePath + "/" + p.ID,
	}
}
