package common

import (
	"context"
	"time"
)

// CronJobStarter is able to start a go routine that periodically calls the provided handler. The time between calls is
// provided as timeToCall
func CronJobStarter(ctx context.Context, handler func(), timeToCall time.Duration) {
	go func() {
		timer := time.NewTimer(timeToCall)
		defer timer.Stop()

		for {
			select {
			case <-timer.C:
				handler()
				timer.Reset(timeToCall)
			case <-ctx.Done():
				return
			}
		}
	}()
}
